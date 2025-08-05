package cmd

import (
	"fmt"
	"os"
	"path/filepath"

	"dotfiles/internal/config"
	"dotfiles/internal/files"
	"dotfiles/internal/packages"
	"dotfiles/internal/scripts"

	"github.com/spf13/cobra"
)

var (
	dryRun      bool
	interactive bool
	noBackup    bool
)

var updateCmd = &cobra.Command{
	Use:   "update",
	Short: "Update dotfiles and packages",
	Long: `Update dotfiles by copying files, installing packages, and running custom scripts.
This command will:
1. Copy all configured files to their destinations
2. Install Homebrew packages (brews and casks)
3. Execute custom installation scripts
4. Run post-installation hooks

Use --dry-run to see what would be changed without making changes.
Use --interactive to show diff preview and ask for confirmation.`,
	RunE: runUpdate,
}

func init() {
	rootCmd.AddCommand(updateCmd)
	updateCmd.Flags().BoolVar(&dryRun, "dry-run", false, "show what would be changed without making changes")
	updateCmd.Flags().BoolVar(&interactive, "interactive", false, "show diff preview and ask for confirmation")
	updateCmd.Flags().BoolVar(&noBackup, "no-backup", false, "skip creating backup before update")
}

func runUpdate(cmd *cobra.Command, args []string) error {
	// Load configuration
	cfg, err := loadConfig()
	if err != nil {
		return fmt.Errorf("failed to load config: %w", err)
	}

	// Get dotfiles directory
	dotfilesDir, err := config.GetDotfilesDir()
	if err != nil {
		return fmt.Errorf("failed to get dotfiles directory: %w", err)
	}

	// Override verbose setting from command line
	if verbose {
		cfg.Settings.Verbose = true
	}

	// Create file mapper
	mapper, err := files.NewMapper(cfg, dotfilesDir)
	if err != nil {
		return fmt.Errorf("failed to create file mapper: %w", err)
	}

	// Handle dry run mode
	if dryRun {
		fmt.Println("🔍 Dry run - showing what would be changed:")
		return showPreviewDiff(mapper, cfg)
	}

	// Show diff and ask for confirmation only if interactive flag is used
	if interactive {
		fmt.Println("🔍 Previewing changes...")
		if err := showPreviewDiff(mapper, cfg); err != nil {
			return fmt.Errorf("failed to show diff: %w", err)
		}

		// Ask for confirmation
		fmt.Print("\n❓ Continue with update? [y/N]: ")
		var response string
		fmt.Scanln(&response)
		if response != "y" && response != "Y" && response != "yes" {
			fmt.Println("Update cancelled.")
			return nil
		}
	}

	fmt.Println("🔧 Updating dotfiles...")

	// Create backup before making changes (unless disabled)
	if !noBackup && cfg.Settings.BackupExisting {
		filesToBackup := getFilesToBackup(mapper, cfg)
		if len(filesToBackup) > 0 {
			backupMgr, err := files.NewBackupManager(cfg.Settings.Verbose)
			if err != nil {
				return fmt.Errorf("failed to create backup manager: %w", err)
			}

			backup, err := backupMgr.CreateBackup(filesToBackup)
			if err != nil {
				fmt.Printf("⚠️  Warning: Failed to create backup: %v\n", err)
				fmt.Println("   Continuing with update anyway...")
			} else if backup != nil {
				fmt.Printf("🗄️  Backup created: %s\n", backup.BackupPath)
				
				// Rotate backups if max count is configured
				if cfg.Settings.MaxBackupCount > 0 {
					if err := backupMgr.RotateBackups(cfg.Settings.MaxBackupCount); err != nil {
						fmt.Printf("⚠️  Warning: Failed to rotate backups: %v\n", err)
					}
				}
			} else {
				// backup is nil but no error - this means no files could be backed up
				fmt.Println("ℹ️  No files needed backup, continuing with update...")
			}
		}
	}

	// Install files
	if err := installFiles(mapper, cfg.Files, "files"); err != nil {
		return fmt.Errorf("failed to install files: %w", err)
	}

	// Install config files
	if err := installFiles(mapper, cfg.Config, "config"); err != nil {
		return fmt.Errorf("failed to install config files: %w", err)
	}

	// Install bin files
	if err := installFiles(mapper, cfg.Bin, "bin"); err != nil {
		return fmt.Errorf("failed to install bin files: %w", err)
	}

	// Install packages
	if err := installPackages(cfg); err != nil {
		return fmt.Errorf("failed to install packages: %w", err)
	}

	// Execute custom scripts
	if err := executeScripts(cfg); err != nil {
		return fmt.Errorf("failed to execute scripts: %w", err)
	}

	fmt.Println("✅ Dotfiles update complete!")
	return nil
}

func installFiles(mapper *files.Mapper, mappings []config.FileMapping, mappingType string) error {
	for _, mapping := range mappings {
		sourcePath, destPath, err := mapper.ResolvePath(mapping, mappingType)
		if err != nil {
			return fmt.Errorf("failed to resolve path for %s: %w", mapping.Source, err)
		}

		// Check if source exists
		if _, err := os.Stat(sourcePath); os.IsNotExist(err) {
			if verbose {
				fmt.Printf("⚠️  Source file not found, skipping: %s\n", sourcePath)
			}
			continue
		}

		// Copy file
		if err := mapper.CopyFile(sourcePath, destPath, mapping.Mode); err != nil {
			return fmt.Errorf("failed to copy file %s: %w", mapping.Source, err)
		}

		// Make executable if specified
		if mapping.Executable {
			if err := os.Chmod(sourcePath, 0755); err != nil {
				return fmt.Errorf("failed to make %s executable: %w", sourcePath, err)
			}
		}
	}
	return nil
}

func loadConfig() (*config.Config, error) {
	var configPath string
	if configFile != "" {
		configPath = configFile
	} else {
		defaultPath, err := config.GetConfigPath()
		if err != nil {
			return nil, err
		}
		configPath = defaultPath
		
		// If default doesn't exist, try the v2 example
		if _, err := os.Stat(configPath); os.IsNotExist(err) {
			dotfilesDir, _ := config.GetDotfilesDir()
			configPath = filepath.Join(dotfilesDir, "dotfiles-v2", "examples", "config.yaml")
		}
	}

	return config.Load(configPath)
}

func installPackages(cfg *config.Config) error {
	homebrewMgr := packages.NewHomebrewManager(cfg.Settings.Verbose)
	
	if !homebrewMgr.IsInstalled() {
		fmt.Println("⚠️  Homebrew not installed, skipping package installation")
		return nil
	}

	if len(cfg.Packages.Homebrew.Taps) > 0 || len(cfg.Packages.Homebrew.Brews) > 0 || len(cfg.Packages.Homebrew.Casks) > 0 {
		fmt.Println("📦 Installing Homebrew packages...")
		if err := homebrewMgr.Install(cfg.Packages.Homebrew); err != nil {
			return fmt.Errorf("failed to install Homebrew packages: %w", err)
		}
	}

	return nil
}

func executeScripts(cfg *config.Config) error {
	if len(cfg.Scripts) == 0 {
		return nil
	}

	executor := scripts.NewExecutor(cfg.Settings.Verbose)
	
	fmt.Println("🔧 Executing custom scripts...")
	return executor.ExecuteScripts(cfg.Scripts)
}

func showPreviewDiff(mapper *files.Mapper, cfg *config.Config) error {
	hasChanges := false

	// Check files diff
	if len(cfg.Files) > 0 {
		fmt.Println("\n📁 Files:")
		if changes, err := showMappingDiff(mapper, cfg.Files, "files"); err != nil {
			return fmt.Errorf("failed to diff files: %w", err)
		} else if changes {
			hasChanges = true
		}
	}

	// Check config files diff
	if len(cfg.Config) > 0 {
		fmt.Println("\n⚙️  Config Files:")
		if changes, err := showMappingDiff(mapper, cfg.Config, "config"); err != nil {
			return fmt.Errorf("failed to diff config files: %w", err)
		} else if changes {
			hasChanges = true
		}
	}

	// Check bin files diff
	if len(cfg.Bin) > 0 {
		fmt.Println("\n🔧 Bin Files:")
		if changes, err := showMappingDiff(mapper, cfg.Bin, "bin"); err != nil {
			return fmt.Errorf("failed to diff bin files: %w", err)
		} else if changes {
			hasChanges = true
		}
	}

	// Check packages diff
	if len(cfg.Packages.Homebrew.Taps) > 0 || len(cfg.Packages.Homebrew.Brews) > 0 || len(cfg.Packages.Homebrew.Casks) > 0 {
		fmt.Println("\n📦 Packages:")
		if changes, err := showPackageDiff(cfg); err != nil {
			return fmt.Errorf("failed to diff packages: %w", err)
		} else if changes {
			hasChanges = true
		}
	}

	// Check scripts diff
	if len(cfg.Scripts) > 0 {
		fmt.Println("\n🔧 Scripts:")
		if changes, err := showScriptsDiff(cfg); err != nil {
			return fmt.Errorf("failed to diff scripts: %w", err)
		} else if changes {
			hasChanges = true
		}
	}

	if !hasChanges {
		fmt.Println("\n🎉 No changes needed - all files, packages, and scripts are up to date!")
	}

	return nil
}

func getFilesToBackup(mapper *files.Mapper, cfg *config.Config) []string {
	var filesToBackup []string

	// Check which files exist and would be changed
	for _, mapping := range cfg.Files {
		_, destPath, err := mapper.ResolvePath(mapping, "files")
		if err != nil {
			continue
		}
		
		// Check if destination exists (either as file or symlink)
		if _, err := os.Lstat(destPath); err == nil {
			filesToBackup = append(filesToBackup, destPath)
		}
	}

	for _, mapping := range cfg.Config {
		_, destPath, err := mapper.ResolvePath(mapping, "config")
		if err != nil {
			continue
		}
		
		if _, err := os.Lstat(destPath); err == nil {
			filesToBackup = append(filesToBackup, destPath)
		}
	}

	for _, mapping := range cfg.Bin {
		_, destPath, err := mapper.ResolvePath(mapping, "bin")
		if err != nil {
			continue
		}
		
		if _, err := os.Lstat(destPath); err == nil {
			filesToBackup = append(filesToBackup, destPath)
		}
	}

	return filesToBackup
}

func showScriptsDiff(cfg *config.Config) (bool, error) {
	executor := scripts.NewExecutor(cfg.Settings.Verbose)
	
	scriptDiffs, err := executor.GetScriptDiff(cfg.Scripts)
	if err != nil {
		return false, fmt.Errorf("failed to get script diff: %w", err)
	}

	hasChanges := false
	for _, diff := range scriptDiffs {
		if diff.Status == scripts.ScriptStatusPending || diff.Status == scripts.ScriptStatusWillRun {
			hasChanges = true
		}
		diff.PrintDiff()
	}
	
	if !hasChanges {
		fmt.Println("  (no scripts to run)")
	}

	return hasChanges, nil
}


