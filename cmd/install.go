package cmd

import (
	"github.com/spf13/cobra"
)

var installCmd = &cobra.Command{
	Use:   "install",
	Short: "Alias for update command (deprecated)",
	Long: `Install dotfiles and packages.
This is an alias for the 'update' command and is deprecated.
Please use 'dotfiles update' instead.`,
	RunE: runUpdate, // Use the same function as update
}

func init() {
	rootCmd.AddCommand(installCmd)
	installCmd.Flags().BoolVar(&dryRun, "dry-run", false, "show what would be changed without making changes")
	installCmd.Flags().BoolVar(&interactive, "interactive", false, "show diff preview and ask for confirmation")
}