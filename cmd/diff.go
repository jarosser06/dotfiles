package cmd

import (
	"fmt"

	"dotfiles/internal/config"
	"dotfiles/internal/files"
	"dotfiles/internal/packages"
	"dotfiles/internal/scripts"

	"github.com/spf13/cobra"
)

var diffCmd = &cobra.Command{
	Use:   "diff",
	Short: "Show differences between source and destination files",
	Long: `Show what changes would be made during installation.
This command compares source files with their destinations and shows:
- New files that would be created
- Modified files and their differences
- Files that are already up to date`,
	RunE: runDiff,
}

func init() {
	rootCmd.AddCommand(diffCmd)
}

func runDiff(cmd *cobra.Command, args []string) error {
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

	// Create file mapper
	mapper, err := files.NewMapper(cfg, dotfilesDir)
	if err != nil {
		return fmt.Errorf("failed to create file mapper: %w", err)
	}

	fmt.Println("🔍 Dotfiles Diff")
	fmt.Println("================")

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
		if changes, err := showScriptsDiffForDiff(cfg); err != nil {
			return fmt.Errorf("failed to diff scripts: %w", err)
		} else if changes {
			hasChanges = true
		}
	}

	if !hasChanges {
		fmt.Println("\n🎉 No changes needed - all files, packages, and scripts are up to date!")
	} else {
		fmt.Println("\n💡 Run 'dotfiles update' to apply these changes")
	}

	return nil
}

func showMappingDiff(mapper *files.Mapper, mappings []config.FileMapping, mappingType string) (bool, error) {
	hasChanges := false

	for _, mapping := range mappings {
		sourcePath, destPath, err := mapper.ResolvePath(mapping, mappingType)
		if err != nil {
			fmt.Printf("  ❌ Error resolving %s: %v\n", mapping.Source, err)
			continue
		}

		// Compare files
		diff, err := mapper.CompareFiles(sourcePath, destPath)
		if err != nil {
			fmt.Printf("  ❌ Error comparing %s: %v\n", mapping.Source, err)
			continue
		}

		// Only show if there are changes
		if diff.Status != files.DiffIdentical {
			diff.PrintDiff()
			hasChanges = true
		} else if verbose {
			diff.PrintDiff()
		}
	}

	if !hasChanges && !verbose {
		fmt.Println("  (no changes)")
	}

	return hasChanges, nil
}

func showPackageDiff(cfg *config.Config) (bool, error) {
	homebrewMgr := packages.NewHomebrewManager(cfg.Settings.Verbose)
	
	diff, err := homebrewMgr.GetPackageDiff(cfg.Packages.Homebrew)
	if err != nil {
		return false, fmt.Errorf("failed to get package diff: %w", err)
	}

	diff.PrintDiff(homebrewMgr.IsInstalled())
	return diff.HasChanges, nil
}

func showScriptsDiffForDiff(cfg *config.Config) (bool, error) {
	executor := scripts.NewExecutor(cfg.Settings)
	
	scriptDiffs, err := executor.GetScriptDiff(cfg.Scripts)
	if err != nil {
		return false, fmt.Errorf("failed to get script diff: %w", err)
	}

	hasChanges := false
	for _, diff := range scriptDiffs {
		if diff.Status == scripts.ScriptStatusPending || diff.Status == scripts.ScriptStatusWillRun {
			hasChanges = true
		}
		if verbose || diff.Status != scripts.ScriptStatusInstalled {
			diff.PrintDiff()
		}
	}
	
	if !hasChanges && !verbose {
		fmt.Println("  (no scripts to run)")
	}

	return hasChanges, nil
}