package scripts

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"dotfiles/internal/config"
)

// Executor handles running custom installation scripts
type Executor struct {
	verbose  bool
	settings config.GlobalSettings
}

// NewExecutor creates a new script executor
func NewExecutor(settings config.GlobalSettings) *Executor {
	return &Executor{
		verbose:  settings.Verbose,
		settings: settings,
	}
}

// ExecuteScripts runs all configured scripts in order
func (e *Executor) ExecuteScripts(scripts []config.ScriptConfig) error {
	if len(scripts) == 0 {
		return nil
	}

	for _, script := range scripts {
		if err := e.ExecuteScript(script); err != nil {
			return fmt.Errorf("failed to execute script '%s': %w", script.Name, err)
		}
	}
	return nil
}

// ExecuteScript runs a single script
func (e *Executor) ExecuteScript(script config.ScriptConfig) error {
	if e.verbose {
		fmt.Printf("🔧 Executing script: %s\n", script.Name)
		if script.Description != "" {
			fmt.Printf("   %s\n", script.Description)
		}
	}

	// Check if script should run
	if script.RunOnce && script.CheckCmd != "" {
		if installed, err := e.checkScriptStatus(script); err != nil {
			return err
		} else if installed {
			if e.verbose {
				fmt.Printf("   ✅ Already installed, skipping\n")
			}
			return nil
		}
	}

	// Set working directory
	workingDir := script.WorkingDir
	if workingDir == "" {
		homeDir, err := os.UserHomeDir()
		if err != nil {
			return fmt.Errorf("failed to get home directory: %w", err)
		}
		workingDir = homeDir
	}

	// Expand ~ in working directory
	if workingDir == "~" {
		homeDir, err := os.UserHomeDir()
		if err != nil {
			return fmt.Errorf("failed to get home directory: %w", err)
		}
		workingDir = homeDir
	} else if strings.HasPrefix(workingDir, "~/") {
		homeDir, err := os.UserHomeDir()
		if err != nil {
			return fmt.Errorf("failed to get home directory: %w", err)
		}
		workingDir = filepath.Join(homeDir, workingDir[2:])
	}

	// Substitute variables in command
	expandedCommand := e.expandVariables(script.Command)

	// Execute the command
	cmd := exec.Command("bash", "-c", expandedCommand)
	cmd.Dir = workingDir
	cmd.Env = os.Environ()

	if e.verbose {
		fmt.Printf("   Running: %s\n", expandedCommand)
		fmt.Printf("   Working dir: %s\n", workingDir)
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
	}

	if err := cmd.Run(); err != nil {
		return fmt.Errorf("command failed: %w", err)
	}

	if e.verbose {
		fmt.Printf("   ✅ Script completed successfully\n")
	}

	return nil
}

// CheckScriptStatus checks if a script needs to be run
func (e *Executor) CheckScriptStatus(script config.ScriptConfig) (bool, error) {
	if script.CheckCmd == "" {
		return false, nil // No check command means always run
	}
	return e.checkScriptStatus(script)
}

// checkScriptStatus runs the check command to see if script is already installed
func (e *Executor) checkScriptStatus(script config.ScriptConfig) (bool, error) {
	cmd := exec.Command("bash", "-c", script.CheckCmd)
	cmd.Env = os.Environ()
	
	// Suppress output for check commands
	cmd.Stdout = nil
	cmd.Stderr = nil
	
	err := cmd.Run()
	return err == nil, nil // Returns true if check command succeeds (exit code 0)
}

// GetScriptDiff shows what scripts would be executed
func (e *Executor) GetScriptDiff(scripts []config.ScriptConfig) ([]ScriptDiff, error) {
	var diffs []ScriptDiff
	
	for _, script := range scripts {
		status := ScriptStatusPending
		
		if script.CheckCmd != "" {
			if installed, err := e.checkScriptStatus(script); err != nil {
				status = ScriptStatusError
			} else if installed {
				if script.RunOnce {
					status = ScriptStatusInstalled
				} else {
					status = ScriptStatusWillRun // Will run even if installed
				}
			}
		}
		
		diffs = append(diffs, ScriptDiff{
			Script: script,
			Status: status,
		})
	}
	
	return diffs, nil
}

// ScriptStatus represents the status of a script
type ScriptStatus int

const (
	ScriptStatusPending ScriptStatus = iota
	ScriptStatusInstalled
	ScriptStatusWillRun
	ScriptStatusError
)

// ScriptDiff represents the diff status of a script
type ScriptDiff struct {
	Script config.ScriptConfig
	Status ScriptStatus
}

// PrintDiff prints the script diff information
func (sd ScriptDiff) PrintDiff() {
	switch sd.Status {
	case ScriptStatusPending:
		fmt.Printf("  🔄 %s - Will install\n", sd.Script.Name)
	case ScriptStatusInstalled:
		fmt.Printf("  ✅ %s - Already installed\n", sd.Script.Name)
	case ScriptStatusWillRun:
		fmt.Printf("  🔄 %s - Will run\n", sd.Script.Name)
	case ScriptStatusError:
		fmt.Printf("  ❌ %s - Check failed\n", sd.Script.Name)
	}
	
	if sd.Script.Description != "" {
		fmt.Printf("     %s\n", sd.Script.Description)
	}
}

// expandVariables replaces variables in command strings
func (e *Executor) expandVariables(command string) string {
	// Get dotfiles repo path and expand ~
	dotfilesPath := e.settings.DotfilesRepoPath
	if dotfilesPath == "" {
		dotfilesPath = "~/.dotfiles" // Default fallback
	}
	
	if dotfilesPath == "~" {
		if homeDir, err := os.UserHomeDir(); err == nil {
			dotfilesPath = homeDir
		}
	} else if strings.HasPrefix(dotfilesPath, "~/") {
		if homeDir, err := os.UserHomeDir(); err == nil {
			dotfilesPath = filepath.Join(homeDir, dotfilesPath[2:])
		}
	}
	
	// Replace variables
	expanded := strings.ReplaceAll(command, "${DOTFILES_REPO}", dotfilesPath)
	expanded = strings.ReplaceAll(expanded, "$DOTFILES_REPO", dotfilesPath)
	
	return expanded
}