package cmd

import (
	"fmt"
	"strconv"

	"dotfiles/internal/files"

	"github.com/spf13/cobra"
)

var backupCmd = &cobra.Command{
	Use:   "backup",
	Short: "Manage dotfile backups",
	Long: `Manage dotfile backups created during updates.

Available subcommands:
  list    - List all available backups
  clean   - Remove old backups by time (days)
  rotate  - Keep only N most recent backups
  
Backups are automatically created when you run 'dotfiles update' (unless disabled).`,
}

var backupListCmd = &cobra.Command{
	Use:   "list",
	Short: "List all available backups",
	Long:  `List all available backups, sorted by date (newest first).`,
	RunE:  runBackupList,
}

var backupCleanCmd = &cobra.Command{
	Use:   "clean [days]",
	Short: "Remove old backups",
	Long: `Remove backups older than the specified number of days.
Default is 30 days if no number is provided.

Examples:
  dotfiles backup clean       # Remove backups older than 30 days
  dotfiles backup clean 7     # Remove backups older than 7 days`,
	RunE: runBackupClean,
}

var backupRotateCmd = &cobra.Command{
	Use:   "rotate [count]",
	Short: "Keep only N most recent backups",
	Long: `Keep only the N most recent backups, removing older ones.
Default is 5 backups if no number is provided.

Examples:
  dotfiles backup rotate      # Keep only 5 most recent backups
  dotfiles backup rotate 3    # Keep only 3 most recent backups`,
	RunE: runBackupRotate,
}

func init() {
	rootCmd.AddCommand(backupCmd)
	backupCmd.AddCommand(backupListCmd)
	backupCmd.AddCommand(backupCleanCmd)
	backupCmd.AddCommand(backupRotateCmd)
}

func runBackupList(cmd *cobra.Command, args []string) error {
	backupMgr, err := files.NewBackupManager(verbose)
	if err != nil {
		return fmt.Errorf("failed to create backup manager: %w", err)
	}

	backups, err := backupMgr.ListBackups()
	if err != nil {
		return fmt.Errorf("failed to list backups: %w", err)
	}

	if len(backups) == 0 {
		fmt.Println("📂 No backups found")
		fmt.Println("💡 Backups are created automatically when you run 'dotfiles update'")
		return nil
	}

	fmt.Printf("📂 Found %d backup(s):\n\n", len(backups))

	for i, backup := range backups {
		fmt.Printf("%d. %s\n", i+1, backup.Timestamp.Format("2006-01-02 15:04:05"))
		fmt.Printf("   📁 %s\n", backup.BackupPath)
		if len(backup.Files) > 0 {
			fmt.Printf("   📋 %d files backed up\n", len(backup.Files))
			if verbose {
				for _, file := range backup.Files {
					fmt.Printf("      - %s\n", file)
				}
			}
		}
		fmt.Println()
	}

	fmt.Println("💡 Use 'dotfiles rollback [number]' to restore from a backup")
	fmt.Println("💡 Use 'dotfiles backup clean' to remove old backups")

	return nil
}

func runBackupClean(cmd *cobra.Command, args []string) error {
	// Default to 30 days
	daysToKeep := 30

	if len(args) > 0 {
		days, err := strconv.Atoi(args[0])
		if err != nil {
			return fmt.Errorf("invalid number of days: %s", args[0])
		}
		if days < 1 {
			return fmt.Errorf("days must be a positive number")
		}
		daysToKeep = days
	}

	backupMgr, err := files.NewBackupManager(verbose)
	if err != nil {
		return fmt.Errorf("failed to create backup manager: %w", err)
	}

	// List backups first to show what will be removed
	backups, err := backupMgr.ListBackups()
	if err != nil {
		return fmt.Errorf("failed to list backups: %w", err)
	}

	if len(backups) == 0 {
		fmt.Println("📂 No backups found")
		return nil
	}

	fmt.Printf("🧹 Cleaning backups older than %d days...\n", daysToKeep)

	if err := backupMgr.CleanOldBackups(daysToKeep); err != nil {
		return fmt.Errorf("failed to clean old backups: %w", err)
	}

	fmt.Println("✅ Backup cleanup complete!")
	return nil
}

func runBackupRotate(cmd *cobra.Command, args []string) error {
	// Default to 5 backups
	maxBackups := 5

	if len(args) > 0 {
		count, err := strconv.Atoi(args[0])
		if err != nil {
			return fmt.Errorf("invalid backup count: %s", args[0])
		}
		if count < 1 {
			return fmt.Errorf("backup count must be a positive number")
		}
		maxBackups = count
	}

	backupMgr, err := files.NewBackupManager(verbose)
	if err != nil {
		return fmt.Errorf("failed to create backup manager: %w", err)
	}

	// List backups first to show current state
	backups, err := backupMgr.ListBackups()
	if err != nil {
		return fmt.Errorf("failed to list backups: %w", err)
	}

	if len(backups) == 0 {
		fmt.Println("📂 No backups found")
		return nil
	}

	fmt.Printf("🔄 Rotating backups to keep only %d most recent...\n", maxBackups)

	if err := backupMgr.RotateBackups(maxBackups); err != nil {
		return fmt.Errorf("failed to rotate backups: %w", err)
	}

	fmt.Println("✅ Backup rotation complete!")
	return nil
}