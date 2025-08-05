package config

import "os"

// Config represents the main configuration structure
type Config struct {
	Files    []FileMapping      `yaml:"files"`
	Config   []FileMapping      `yaml:"config"`
	Bin      []FileMapping      `yaml:"bin"`
	Packages PackageConfig      `yaml:"packages"`
	Scripts  []ScriptConfig     `yaml:"scripts"`
	Profiles map[string]Profile `yaml:"profiles"`
	Hooks    HookConfig         `yaml:"hooks"`
	Settings GlobalSettings     `yaml:"settings"`
}

// FileMapping represents a file or directory mapping
type FileMapping struct {
	Source     string      `yaml:"source"`
	Dest       string      `yaml:"dest,omitempty"`
	Mode       os.FileMode `yaml:"mode,omitempty"`
	Profile    string      `yaml:"profile,omitempty"`
	Executable bool        `yaml:"executable,omitempty"`
}

// PackageConfig represents package manager configurations
type PackageConfig struct {
	Homebrew HomebrewConfig `yaml:"homebrew"`
}

// HomebrewConfig represents Homebrew package configuration
type HomebrewConfig struct {
	Taps  []string `yaml:"taps"`
	Brews []string `yaml:"brews"`
	Casks []string `yaml:"casks"`
}

// ScriptConfig represents a custom installation script
type ScriptConfig struct {
	Name        string `yaml:"name"`
	Description string `yaml:"description,omitempty"`
	Command     string `yaml:"command"`
	WorkingDir  string `yaml:"working_dir,omitempty"`
	CheckCmd    string `yaml:"check_cmd,omitempty"`
	Profile     string `yaml:"profile,omitempty"`
	RunOnce     bool   `yaml:"run_once,omitempty"`
}

// Profile represents a profile-specific configuration
type Profile struct {
	Files    []FileMapping  `yaml:"files"`
	Packages PackageConfig  `yaml:"packages"`
	Scripts  []ScriptConfig `yaml:"scripts"`
	Hooks    HookConfig     `yaml:"hooks"`
}

// HookConfig represents pre/post installation hooks
type HookConfig struct {
	PreInstall  []string `yaml:"pre_install"`
	PostInstall []string `yaml:"post_install"`
}

// GlobalSettings represents global framework settings
type GlobalSettings struct {
	BackupExisting      bool   `yaml:"backup_existing"`
	CreateDirectories   bool   `yaml:"create_directories"`
	Verbose             bool   `yaml:"verbose"`
	BackupRetentionDays int    `yaml:"backup_retention_days"`
	MaxBackupCount      int    `yaml:"max_backup_count"`
	DotfilesRepoPath    string `yaml:"dotfiles_repo_path"`
}