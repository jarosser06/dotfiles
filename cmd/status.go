package cmd

import (
	"fmt"
	"os"

	"dotfiles/internal/config"
	"dotfiles/internal/files"
	"dotfiles/internal/packages"
	"dotfiles/internal/scripts"

	"github.com/spf13/cobra"
)

var statusCmd = &cobra.Command{
	Use:   "status",
	Short: "Show dotfiles installation status",
	Long:  `Display the current status of dotfiles, including which files are linked and which packages are installed.`,
	RunE:  runStatus,
}

func init() {
	rootCmd.AddCommand(statusCmd)
}

func runStatus(cmd *cobra.Command, args []string) error {
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

	fmt.Println("📊 Dotfiles Status")
	fmt.Println("==================")

	// Check files status
	fmt.Println("\n📁 Files:")
	checkMappingStatus(mapper, cfg.Files, "files")

	// Check config files status
	fmt.Println("\n⚙️  Config Files:")
	checkMappingStatus(mapper, cfg.Config, "config")

	// Check bin files status
	fmt.Println("\n🔧 Bin Files:")
	checkMappingStatus(mapper, cfg.Bin, "bin")

	// Check packages status
	fmt.Println("\n📦 Packages:")
	checkPackageStatus(cfg)

	// Check scripts status
	fmt.Println("\n🔧 Scripts:")
	checkScriptStatus(cfg)

	return nil
}

func checkMappingStatus(mapper *files.Mapper, mappings []config.FileMapping, mappingType string) {
	if len(mappings) == 0 {
		fmt.Println("  (none configured)")
		return
	}

	for _, mapping := range mappings {
		sourcePath, destPath, err := mapper.ResolvePath(mapping, mappingType)
		if err != nil {
			fmt.Printf("  ❌ %s (error: %v)\n", mapping.Source, err)
			continue
		}

		// Check if source exists
		if _, err := os.Stat(sourcePath); os.IsNotExist(err) {
			fmt.Printf("  ⚠️  %s (source missing)\n", mapping.Source)
			continue
		}

		// Check if destination exists as a regular file
		if info, err := os.Stat(destPath); err == nil {
			if info.Mode().IsRegular() || info.IsDir() {
				fmt.Printf("  ✅ %s → %s\n", mapping.Source, destPath)
			} else {
				fmt.Printf("  ⚠️  %s → %s (not a regular file)\n", mapping.Source, destPath)
			}
		} else {
			fmt.Printf("  ❌ %s (not installed)\n", mapping.Source)
		}
	}
}

func checkPackageStatus(cfg *config.Config) {
	homebrewMgr := packages.NewHomebrewManager(cfg.Settings.Verbose)
	
	if !homebrewMgr.IsInstalled() {
		fmt.Println("  ❌ Homebrew not installed")
		return
	}

	// Check taps
	if len(cfg.Packages.Homebrew.Taps) > 0 {
		fmt.Println("  Taps:")
		for _, tap := range cfg.Packages.Homebrew.Taps {
			if isTapInstalled(tap) {
				fmt.Printf("    ✅ %s\n", tap)
			} else {
				fmt.Printf("    ❌ %s (not installed)\n", tap)
			}
		}
	}

	// Check brews
	if len(cfg.Packages.Homebrew.Brews) > 0 {
		fmt.Println("  Brews:")
		for _, brew := range cfg.Packages.Homebrew.Brews {
			if homebrewMgr.IsBrewInstalled(brew) {
				fmt.Printf("    ✅ %s\n", brew)
			} else {
				fmt.Printf("    ❌ %s (not installed)\n", brew)
			}
		}
	}

	// Check casks
	if len(cfg.Packages.Homebrew.Casks) > 0 {
		fmt.Println("  Casks:")
		for _, cask := range cfg.Packages.Homebrew.Casks {
			if homebrewMgr.IsCaskInstalled(cask) {
				fmt.Printf("    ✅ %s\n", cask)
			} else {
				fmt.Printf("    ❌ %s (not installed)\n", cask)
			}
		}
	}

	if len(cfg.Packages.Homebrew.Taps) == 0 && len(cfg.Packages.Homebrew.Brews) == 0 && len(cfg.Packages.Homebrew.Casks) == 0 {
		fmt.Println("  (no packages configured)")
	}
}

func isTapInstalled(tap string) bool {
	// Simple implementation - could be improved
	return false // For now, assume not installed for demo
}

func checkScriptStatus(cfg *config.Config) {
	if len(cfg.Scripts) == 0 {
		fmt.Println("  (none configured)")
		return
	}

	executor := scripts.NewExecutor(cfg.Settings.Verbose)

	for _, script := range cfg.Scripts {
		if script.CheckCmd == "" {
			fmt.Printf("  ❓ %s (no check command)\n", script.Name)
			continue
		}

		if installed, err := executor.CheckScriptStatus(script); err != nil {
			fmt.Printf("  ❌ %s (check failed)\n", script.Name)
		} else if installed {
			fmt.Printf("  ✅ %s\n", script.Name)
		} else {
			fmt.Printf("  ❌ %s (not installed)\n", script.Name)
		}
	}
}