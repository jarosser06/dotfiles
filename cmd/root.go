package cmd

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

var (
	configFile string
	verbose    bool
)

// rootCmd represents the base command when called without any subcommands
var rootCmd = &cobra.Command{
	Use:   "dotfiles",
	Short: "A modern dotfiles management framework for macOS",
	Long: `Dotfiles v2 is a modern, Go-based dotfiles management framework
designed specifically for macOS. It provides flexible file mapping,
Homebrew integration, and profile-based configurations.

Examples:
  dotfiles update           # Update all dotfiles and packages
  dotfiles update --interactive # Show diff and ask for confirmation
  dotfiles profile work     # Switch to work profile
  dotfiles status           # Show current status`,
}

// Execute adds all child commands to the root command and sets flags appropriately.
func Execute() {
	err := rootCmd.Execute()
	if err != nil {
		os.Exit(1)
	}
}

func init() {
	cobra.OnInitialize(initConfig)

	// Global flags
	rootCmd.PersistentFlags().StringVar(&configFile, "config", "", "config file (default is $HOME/.dotfiles/config.yaml)")
	rootCmd.PersistentFlags().BoolVarP(&verbose, "verbose", "v", false, "verbose output")
}

// initConfig reads in config file and ENV variables if set.
func initConfig() {
	if verbose {
		fmt.Println("Verbose mode enabled")
	}
}