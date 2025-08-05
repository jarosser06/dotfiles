package cmd

import (
	"fmt"
	"os"
	"path/filepath"

	"dotfiles/internal/config"
	"dotfiles/internal/files"

	"github.com/spf13/cobra"
)

var profileCmd = &cobra.Command{
	Use:   "profile [profile-name]",
	Short: "Switch to a specific profile",
	Long: `Switch to a specific profile configuration (e.g., work, personal).
This will install profile-specific files and packages.`,
	Args: cobra.ExactArgs(1),
	RunE: runProfile,
}

var listProfilesCmd = &cobra.Command{
	Use:   "list",
	Short: "List available profiles",
	Long:  `List all available profiles configured in the dotfiles.`,
	RunE:  runListProfiles,
}

func init() {
	rootCmd.AddCommand(profileCmd)
	profileCmd.AddCommand(listProfilesCmd)
}

func runProfile(cmd *cobra.Command, args []string) error {
	profileName := args[0]

	// Load configuration
	cfg, err := loadConfig()
	if err != nil {
		return fmt.Errorf("failed to load config: %w", err)
	}

	// Check if profile exists
	profile, exists := cfg.Profiles[profileName]
	if !exists {
		return fmt.Errorf("profile '%s' not found. Available profiles: %v", profileName, getProfileNames(cfg))
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

	fmt.Printf("🔄 Switching to profile: %s\n", profileName)

	// Install profile-specific files
	if len(profile.Files) > 0 {
		fmt.Println("📁 Installing profile files...")
		if err := installFiles(mapper, profile.Files, "files"); err != nil {
			return fmt.Errorf("failed to install profile files: %w", err)
		}
	}

	// Run profile-specific hooks
	if len(profile.Hooks.PreInstall) > 0 {
		fmt.Println("🪝 Running pre-install hooks...")
		if err := runHooks(profile.Hooks.PreInstall); err != nil {
			return fmt.Errorf("failed to run pre-install hooks: %w", err)
		}
	}

	if len(profile.Hooks.PostInstall) > 0 {
		fmt.Println("🪝 Running post-install hooks...")
		if err := runHooks(profile.Hooks.PostInstall); err != nil {
			return fmt.Errorf("failed to run post-install hooks: %w", err)
		}
	}

	// Save current profile
	if err := saveCurrentProfile(profileName); err != nil {
		fmt.Printf("⚠️  Warning: failed to save current profile: %v\n", err)
	}

	fmt.Printf("✅ Successfully switched to profile: %s\n", profileName)
	return nil
}

func runListProfiles(cmd *cobra.Command, args []string) error {
	// Load configuration
	cfg, err := loadConfig()
	if err != nil {
		return fmt.Errorf("failed to load config: %w", err)
	}

	fmt.Println("📋 Available Profiles:")
	fmt.Println("=====================")

	if len(cfg.Profiles) == 0 {
		fmt.Println("No profiles configured.")
		return nil
	}

	// Get current profile
	currentProfile := getCurrentProfile()

	for name, profile := range cfg.Profiles {
		current := ""
		if name == currentProfile {
			current = " (current)"
		}

		fmt.Printf("\n🔖 %s%s\n", name, current)
		if len(profile.Files) > 0 {
			fmt.Printf("   Files: %d configured\n", len(profile.Files))
		}
		if len(profile.Packages.Homebrew.Brews) > 0 || len(profile.Packages.Homebrew.Casks) > 0 {
			fmt.Printf("   Packages: %d brews, %d casks\n", 
				len(profile.Packages.Homebrew.Brews), 
				len(profile.Packages.Homebrew.Casks))
		}
		if len(profile.Hooks.PreInstall) > 0 || len(profile.Hooks.PostInstall) > 0 {
			fmt.Printf("   Hooks: %d pre-install, %d post-install\n", 
				len(profile.Hooks.PreInstall), 
				len(profile.Hooks.PostInstall))
		}
	}

	return nil
}

func getProfileNames(cfg *config.Config) []string {
	names := make([]string, 0, len(cfg.Profiles))
	for name := range cfg.Profiles {
		names = append(names, name)
	}
	return names
}

func saveCurrentProfile(profileName string) error {
	dotfilesDir, err := config.GetDotfilesDir()
	if err != nil {
		return err
	}

	profileFile := filepath.Join(dotfilesDir, ".current_profile")
	return os.WriteFile(profileFile, []byte(profileName), 0644)
}

func getCurrentProfile() string {
	dotfilesDir, err := config.GetDotfilesDir()
	if err != nil {
		return ""
	}

	profileFile := filepath.Join(dotfilesDir, ".current_profile")
	data, err := os.ReadFile(profileFile)
	if err != nil {
		return ""
	}

	return string(data)
}

func runHooks(hooks []string) error {
	for _, hook := range hooks {
		if verbose {
			fmt.Printf("Running hook: %s\n", hook)
		}
		// For now, just print the hooks - would need shell execution
		fmt.Printf("  Hook: %s\n", hook)
	}
	return nil
}