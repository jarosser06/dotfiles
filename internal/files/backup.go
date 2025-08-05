package files

import (
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"time"
)

// BackupManager handles creating and managing backups
type BackupManager struct {
	backupDir string
	verbose   bool
}

// BackupInfo represents information about a backup
type BackupInfo struct {
	Timestamp  time.Time
	BackupPath string
	Files      []string
}

// NewBackupManager creates a new backup manager
func NewBackupManager(verbose bool) (*BackupManager, error) {
	homeDir, err := os.UserHomeDir()
	if err != nil {
		return nil, fmt.Errorf("failed to get home directory: %w", err)
	}

	backupDir := filepath.Join(homeDir, ".dotfiles-backups")
	
	// Create backup directory if it doesn't exist
	if err := os.MkdirAll(backupDir, 0755); err != nil {
		return nil, fmt.Errorf("failed to create backup directory: %w", err)
	}

	return &BackupManager{
		backupDir: backupDir,
		verbose:   verbose,
	}, nil
}

// CreateBackup creates a timestamped backup of files that would be changed
func (bm *BackupManager) CreateBackup(filesToBackup []string) (*BackupInfo, error) {
	if len(filesToBackup) == 0 {
		return nil, nil // No files to backup
	}

	timestamp := time.Now().Format("2006-01-02_15-04-05")
	backupPath := filepath.Join(bm.backupDir, fmt.Sprintf("backup_%s", timestamp))
	
	if bm.verbose {
		fmt.Printf("🗄️  Creating backup at %s\n", backupPath)
	}

	// Create backup directory
	if err := os.MkdirAll(backupPath, 0755); err != nil {
		return nil, fmt.Errorf("failed to create backup directory: %w", err)
	}

	var backedUpFiles []string
	
	for _, filePath := range filesToBackup {
		if err := bm.backupFile(filePath, backupPath); err != nil {
			return nil, fmt.Errorf("failed to backup %s: %w", filePath, err)
		}
		backedUpFiles = append(backedUpFiles, filePath)
	}

	// Create backup metadata
	backupInfo := &BackupInfo{
		Timestamp:  time.Now(),
		BackupPath: backupPath,
		Files:      backedUpFiles,
	}

	if err := bm.saveBackupMetadata(backupInfo); err != nil {
		return nil, fmt.Errorf("failed to save backup metadata: %w", err)
	}

	if bm.verbose {
		fmt.Printf("✅ Backup created with %d files\n", len(backedUpFiles))
	}

	return backupInfo, nil
}

// backupFile backs up a single file, preserving directory structure
func (bm *BackupManager) backupFile(sourcePath, backupPath string) error {
	// Skip if source doesn't exist
	if _, err := os.Stat(sourcePath); os.IsNotExist(err) {
		return nil
	}

	// Determine relative path for backup
	homeDir, _ := os.UserHomeDir()
	relPath, err := filepath.Rel(homeDir, sourcePath)
	if err != nil {
		// If can't make relative, use full path structure
		relPath = strings.TrimPrefix(sourcePath, "/")
	}

	destPath := filepath.Join(backupPath, relPath)
	destDir := filepath.Dir(destPath)

	// Create destination directory
	if err := os.MkdirAll(destDir, 0755); err != nil {
		return fmt.Errorf("failed to create backup subdirectory: %w", err)
	}

	// Check if it's a symlink
	if info, err := os.Lstat(sourcePath); err == nil && info.Mode()&os.ModeSymlink != 0 {
		// Backup symlink target
		target, err := os.Readlink(sourcePath)
		if err != nil {
			return fmt.Errorf("failed to read symlink: %w", err)
		}
		
		// Save symlink info to a .link file
		linkInfoPath := destPath + ".link"
		return os.WriteFile(linkInfoPath, []byte(target), 0644)
	}

	// Regular file or directory - copy it
	return bm.copyFileOrDir(sourcePath, destPath)
}

// copyFileOrDir copies a file or directory recursively
func (bm *BackupManager) copyFileOrDir(src, dst string) error {
	srcInfo, err := os.Stat(src)
	if err != nil {
		return err
	}

	if srcInfo.IsDir() {
		return bm.copyDir(src, dst)
	}
	return bm.copyFile(src, dst)
}

// copyFile copies a single file
func (bm *BackupManager) copyFile(src, dst string) error {
	srcFile, err := os.Open(src)
	if err != nil {
		return err
	}
	defer srcFile.Close()

	dstFile, err := os.Create(dst)
	if err != nil {
		return err
	}
	defer dstFile.Close()

	_, err = srcFile.WriteTo(dstFile)
	if err != nil {
		return err
	}

	// Copy permissions
	srcInfo, err := os.Stat(src)
	if err != nil {
		return err
	}
	return os.Chmod(dst, srcInfo.Mode())
}

// copyDir copies a directory recursively
func (bm *BackupManager) copyDir(src, dst string) error {
	srcInfo, err := os.Stat(src)
	if err != nil {
		return err
	}

	if err := os.MkdirAll(dst, srcInfo.Mode()); err != nil {
		return err
	}

	entries, err := os.ReadDir(src)
	if err != nil {
		return err
	}

	for _, entry := range entries {
		srcPath := filepath.Join(src, entry.Name())
		dstPath := filepath.Join(dst, entry.Name())

		if err := bm.copyFileOrDir(srcPath, dstPath); err != nil {
			return err
		}
	}

	return nil
}

// saveBackupMetadata saves backup information
func (bm *BackupManager) saveBackupMetadata(info *BackupInfo) error {
	metadataPath := filepath.Join(info.BackupPath, "backup_info.txt")
	
	content := fmt.Sprintf("Backup created: %s\n", info.Timestamp.Format(time.RFC3339))
	content += fmt.Sprintf("Files backed up: %d\n\n", len(info.Files))
	
	for _, file := range info.Files {
		content += fmt.Sprintf("- %s\n", file)
	}

	return os.WriteFile(metadataPath, []byte(content), 0644)
}

// ListBackups returns a list of available backups, sorted by date (newest first)
func (bm *BackupManager) ListBackups() ([]*BackupInfo, error) {
	entries, err := os.ReadDir(bm.backupDir)
	if err != nil {
		if os.IsNotExist(err) {
			return []*BackupInfo{}, nil // No backups directory
		}
		return nil, fmt.Errorf("failed to read backup directory: %w", err)
	}

	var backups []*BackupInfo
	
	for _, entry := range entries {
		if !entry.IsDir() || !strings.HasPrefix(entry.Name(), "backup_") {
			continue
		}

		backupPath := filepath.Join(bm.backupDir, entry.Name())
		
		// Extract timestamp from directory name
		timestampStr := strings.TrimPrefix(entry.Name(), "backup_")
		timestamp, err := time.Parse("2006-01-02_15-04-05", timestampStr)
		if err != nil {
			continue // Skip invalid backup directories
		}

		// Read backup metadata if available
		var files []string
		metadataPath := filepath.Join(backupPath, "backup_info.txt")
		if data, err := os.ReadFile(metadataPath); err == nil {
			lines := strings.Split(string(data), "\n")
			for _, line := range lines {
				if strings.HasPrefix(line, "- ") {
					files = append(files, strings.TrimPrefix(line, "- "))
				}
			}
		}

		backups = append(backups, &BackupInfo{
			Timestamp:  timestamp,
			BackupPath: backupPath,
			Files:      files,
		})
	}

	// Sort by timestamp (newest first)
	sort.Slice(backups, func(i, j int) bool {
		return backups[i].Timestamp.After(backups[j].Timestamp)
	})

	return backups, nil
}

// RestoreBackup restores files from a specific backup
func (bm *BackupManager) RestoreBackup(backupPath string) error {
	if bm.verbose {
		fmt.Printf("🔄 Restoring from backup: %s\n", backupPath)
	}

	homeDir, err := os.UserHomeDir()
	if err != nil {
		return fmt.Errorf("failed to get home directory: %w", err)
	}

	return filepath.Walk(backupPath, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		// Skip the backup directory itself and metadata files
		if path == backupPath || strings.HasSuffix(path, "backup_info.txt") {
			return nil
		}

		// Calculate relative path
		relPath, err := filepath.Rel(backupPath, path)
		if err != nil {
			return err
		}

		destPath := filepath.Join(homeDir, relPath)

		// Handle symlink files
		if strings.HasSuffix(path, ".link") {
			return bm.restoreSymlink(path, destPath)
		}

		// Skip .link files (they're handled above)
		if strings.HasSuffix(relPath, ".link") {
			return nil
		}

		if info.IsDir() {
			// Create directory
			if err := os.MkdirAll(destPath, info.Mode()); err != nil {
				return fmt.Errorf("failed to create directory %s: %w", destPath, err)
			}
		} else {
			// Restore file
			if err := bm.copyFile(path, destPath); err != nil {
				return fmt.Errorf("failed to restore file %s: %w", destPath, err)
			}
		}

		if bm.verbose {
			fmt.Printf("  Restored: %s\n", destPath)
		}

		return nil
	})
}

// restoreSymlink restores a symlink from backup
func (bm *BackupManager) restoreSymlink(linkFilePath, destPath string) error {
	// Remove .link extension to get the actual destination
	actualDestPath := strings.TrimSuffix(destPath, ".link")
	
	// Read the symlink target
	targetBytes, err := os.ReadFile(linkFilePath)
	if err != nil {
		return fmt.Errorf("failed to read symlink info: %w", err)
	}
	target := strings.TrimSpace(string(targetBytes))

	// Remove existing file/symlink
	os.Remove(actualDestPath)

	// Create the symlink
	if err := os.Symlink(target, actualDestPath); err != nil {
		return fmt.Errorf("failed to create symlink: %w", err)
	}

	if bm.verbose {
		fmt.Printf("  Restored symlink: %s → %s\n", actualDestPath, target)
	}

	return nil
}

// CleanOldBackups removes backups older than the specified number of days
func (bm *BackupManager) CleanOldBackups(daysToKeep int) error {
	backups, err := bm.ListBackups()
	if err != nil {
		return err
	}

	cutoffTime := time.Now().AddDate(0, 0, -daysToKeep)
	var removedCount int

	for _, backup := range backups {
		if backup.Timestamp.Before(cutoffTime) {
			if bm.verbose {
				fmt.Printf("🗑️  Removing old backup: %s\n", backup.BackupPath)
			}
			
			if err := os.RemoveAll(backup.BackupPath); err != nil {
				return fmt.Errorf("failed to remove backup %s: %w", backup.BackupPath, err)
			}
			removedCount++
		}
	}

	if bm.verbose && removedCount > 0 {
		fmt.Printf("✅ Removed %d old backups\n", removedCount)
	}

	return nil
}

// RotateBackups keeps only the N most recent backups, removing older ones
func (bm *BackupManager) RotateBackups(maxBackups int) error {
	backups, err := bm.ListBackups()
	if err != nil {
		return err
	}

	if len(backups) <= maxBackups {
		return nil // No rotation needed
	}

	// Remove excess backups (backups are already sorted newest first)
	backupsToRemove := backups[maxBackups:]
	var removedCount int

	for _, backup := range backupsToRemove {
		if bm.verbose {
			fmt.Printf("🗑️  Rotating out backup: %s\n", backup.BackupPath)
		}
		
		if err := os.RemoveAll(backup.BackupPath); err != nil {
			return fmt.Errorf("failed to remove backup %s: %w", backup.BackupPath, err)
		}
		removedCount++
	}

	if bm.verbose && removedCount > 0 {
		fmt.Printf("✅ Rotated out %d old backups (keeping %d most recent)\n", removedCount, maxBackups)
	}

	return nil
}