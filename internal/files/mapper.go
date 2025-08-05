package files

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"dotfiles/internal/config"
)

// Mapper handles file operations and mappings
type Mapper struct {
	config      *config.Config
	dotfilesDir string
	homeDir     string
}

// NewMapper creates a new file mapper
func NewMapper(cfg *config.Config, dotfilesDir string) (*Mapper, error) {
	homeDir, err := os.UserHomeDir()
	if err != nil {
		return nil, fmt.Errorf("failed to get home directory: %w", err)
	}

	return &Mapper{
		config:      cfg,
		dotfilesDir: dotfilesDir,
		homeDir:     homeDir,
	}, nil
}

// ResolvePath resolves a file mapping to source and destination paths
func (m *Mapper) ResolvePath(mapping config.FileMapping, mappingType string) (string, string, error) {
	// Source path (always relative to dotfiles directory)
	var sourcePath string
	switch mappingType {
	case "files":
		sourcePath = filepath.Join(m.dotfilesDir, "files", mapping.Source)
	case "config":
		sourcePath = filepath.Join(m.dotfilesDir, "config", mapping.Source)
	case "bin":
		sourcePath = filepath.Join(m.dotfilesDir, "bin", mapping.Source)
	default:
		return "", "", fmt.Errorf("unknown mapping type: %s", mappingType)
	}

	// Destination path
	var destPath string
	if mapping.Dest != "" {
		// Explicit destination
		if strings.HasPrefix(mapping.Dest, "~/") {
			destPath = filepath.Join(m.homeDir, mapping.Dest[2:])
		} else {
			destPath = mapping.Dest
		}
	} else {
		// Implicit destination based on type
		switch mappingType {
		case "files":
			// Add dot prefix for files in home directory
			destPath = filepath.Join(m.homeDir, "."+mapping.Source)
		case "config":
			// XDG config directory
			destPath = filepath.Join(m.homeDir, ".config", mapping.Source)
		case "bin":
			// Local bin directory
			destPath = filepath.Join(m.homeDir, ".local", "bin", filepath.Base(mapping.Source))
		}
	}

	return sourcePath, destPath, nil
}

// CopyFile copies a file or directory from source to destination
func (m *Mapper) CopyFile(sourcePath, destPath string, mode os.FileMode) error {
	// Create destination directory if needed
	if m.config.Settings.CreateDirectories {
		destDir := filepath.Dir(destPath)
		if err := os.MkdirAll(destDir, 0755); err != nil {
			return fmt.Errorf("failed to create directory %s: %w", destDir, err)
		}
	}

	// Check if source is a directory
	srcInfo, err := os.Stat(sourcePath)
	if err != nil {
		return fmt.Errorf("failed to stat source %s: %w", sourcePath, err)
	}

	if srcInfo.IsDir() {
		// For directories, merge content instead of replacing
		if m.config.Settings.Verbose {
			fmt.Printf("Merging directory: %s → %s\n", sourcePath, destPath)
		}
		return m.copyDir(sourcePath, destPath)
	} else {
		// For files, remove existing destination (backup is handled at higher level now)
		if _, err := os.Lstat(destPath); err == nil {
			if err := os.RemoveAll(destPath); err != nil {
				return fmt.Errorf("failed to remove existing file %s: %w", destPath, err)
			}
		}

		// Copy file
		if err := m.copyFileContent(sourcePath, destPath); err != nil {
			return fmt.Errorf("failed to copy %s → %s: %w", sourcePath, destPath, err)
		}

		if m.config.Settings.Verbose {
			fmt.Printf("Copied file: %s → %s\n", sourcePath, destPath)
		}
	}

	// Set permissions if specified
	if mode != 0 {
		if err := os.Chmod(destPath, mode); err != nil {
			return fmt.Errorf("failed to set permissions on %s: %w", destPath, err)
		}
	}

	return nil
}

// copyFileOrDir copies a file or directory recursively
func (m *Mapper) copyFileOrDir(src, dst string) error {
	srcInfo, err := os.Stat(src)
	if err != nil {
		return err
	}

	if srcInfo.IsDir() {
		return m.copyDir(src, dst)
	}
	return m.copyFileContent(src, dst)
}

// copyFileContent copies a single file's content
func (m *Mapper) copyFileContent(src, dst string) error {
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

	if _, err := srcFile.WriteTo(dstFile); err != nil {
		return err
	}

	// Copy permissions
	srcInfo, err := os.Stat(src)
	if err != nil {
		return err
	}
	return os.Chmod(dst, srcInfo.Mode())
}

// copyDir copies a directory recursively, merging with existing content
func (m *Mapper) copyDir(src, dst string) error {
	srcInfo, err := os.Stat(src)
	if err != nil {
		return err
	}

	// Create destination directory if it doesn't exist
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

		srcEntryInfo, err := os.Stat(srcPath)
		if err != nil {
			return err
		}

		if srcEntryInfo.IsDir() {
			// Recursively merge subdirectories
			if err := m.copyDir(srcPath, dstPath); err != nil {
				return err
			}
		} else {
			// For files, only overwrite if the destination doesn't exist or if it's different
			if _, err := os.Stat(dstPath); err == nil {
				// File exists - check if we should overwrite
				if m.config.Settings.Verbose {
					fmt.Printf("Overwriting existing file: %s\n", dstPath)
				}
			}
			// Copy/overwrite the file
			if err := m.copyFileContent(srcPath, dstPath); err != nil {
				return err
			}
		}
	}

	return nil
}