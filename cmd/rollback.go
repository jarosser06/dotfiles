package cmd

import (
	"fmt"
	"strconv"

	"dotfiles/internal/files"

	"github.com/spf13/cobra"
)

var rollbackCmd = &cobra.Command{
	Use:   "rollback [backup-number]",
	Short: "Rollback to a previous backup",
	Long: `Rollback dotfiles to a previous backup.

Use 'dotfiles backup list' to see available backups.
Specify a backup number (1 = most recent, 2 = second most recent, etc.)
If no number is provided, defaults to the most recent backup.

Examples:
  dotfiles rollback       # Rollback to most recent backup
  dotfiles rollback 2     # Rollback to second most recent backup`,
	RunE: runRollback,
}

func init() {
	rootCmd.AddCommand(rollbackCmd)
}

func runRollback(cmd *cobra.Command, args []string) error {
	backupMgr, err := files.NewBackupManager(verbose)
	if err != nil {
		return fmt.Errorf("failed to create backup manager: %w", err)
	}

	// List available backups
	backups, err := backupMgr.ListBackups()
	if err != nil {
		return fmt.Errorf("failed to list backups: %w", err)
	}

	if len(backups) == 0 {
		fmt.Println("❌ No backups found")
		fmt.Println("Backups are created automatically when you run 'dotfiles update'")
		return nil
	}

	// Determine which backup to restore
	backupIndex := 0 // Default to most recent
	if len(args) > 0 {
		index, err := strconv.Atoi(args[0])
		if err != nil {
			return fmt.Errorf("invalid backup number: %s", args[0])
		}
		if index < 1 || index > len(backups) {
			return fmt.Errorf("backup number must be between 1 and %d", len(backups))
		}
		backupIndex = index - 1 // Convert to 0-based index
	}

	selectedBackup := backups[backupIndex]
	
	fmt.Printf("🔄 Rolling back to backup from %s\n", selectedBackup.Timestamp.Format("2006-01-02 15:04:05"))
	fmt.Printf("📁 Backup location: %s\n", selectedBackup.BackupPath)
	
	if len(selectedBackup.Files) > 0 {
		fmt.Printf("📋 Files to restore: %d\n", len(selectedBackup.Files))
		if verbose {
			for _, file := range selectedBackup.Files {
				fmt.Printf("  - %s\n", file)
			}
		}
	}

	// Ask for confirmation unless in non-interactive mode
	if !isNonInteractive() {
		fmt.Print("\n❓ Continue with rollback? [y/N]: ")
		var response string
		fmt.Scanln(&response)
		if response != "y" && response != "Y" && response != "yes" {
			fmt.Println("Rollback cancelled.")
			return nil
		}
	}

	// Perform the rollback
	if err := backupMgr.RestoreBackup(selectedBackup.BackupPath); err != nil {
		return fmt.Errorf("failed to restore backup: %w", err)
	}

	fmt.Println("✅ Rollback complete!")
	fmt.Printf("🎯 Restored %d files from backup\n", len(selectedBackup.Files))
	
	return nil
}

// isNonInteractive checks if we're running in a non-interactive environment
func isNonInteractive() bool {
	// Simple check - could be enhanced later
	return false
}