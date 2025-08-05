package config

import (
	"fmt"
	"os"
	"path/filepath"

	"gopkg.in/yaml.v3"
)

// Load reads and parses the configuration file
func Load(configPath string) (*Config, error) {
	data, err := os.ReadFile(configPath)
	if err != nil {
		return nil, fmt.Errorf("failed to read config file: %w", err)
	}

	var config Config
	if err := yaml.Unmarshal(data, &config); err != nil {
		return nil, fmt.Errorf("failed to parse config file: %w", err)
	}

	// Set defaults
	if config.Settings.BackupExisting == false {
		config.Settings.BackupExisting = true
	}
	if config.Settings.CreateDirectories == false {
		config.Settings.CreateDirectories = true
	}

	return &config, nil
}

// GetDotfilesDir returns the dotfiles directory path
func GetDotfilesDir() (string, error) {
	home, err := os.UserHomeDir()
	if err != nil {
		return "", fmt.Errorf("failed to get home directory: %w", err)
	}
	return filepath.Join(home, ".dotfiles"), nil
}

// GetConfigPath returns the default config file path
func GetConfigPath() (string, error) {
	dotfilesDir, err := GetDotfilesDir()
	if err != nil {
		return "", err
	}
	return filepath.Join(dotfilesDir, "config.yaml"), nil
}