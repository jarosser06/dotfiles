package packages

import (
	"fmt"
	"os/exec"
	"strings"

	"dotfiles/internal/config"
)

// HomebrewManager handles Homebrew package operations
type HomebrewManager struct {
	verbose bool
}

// NewHomebrewManager creates a new Homebrew manager
func NewHomebrewManager(verbose bool) *HomebrewManager {
	return &HomebrewManager{verbose: verbose}
}

// IsInstalled checks if Homebrew is installed
func (h *HomebrewManager) IsInstalled() bool {
	_, err := exec.LookPath("brew")
	return err == nil
}

// Install installs Homebrew packages based on configuration
func (h *HomebrewManager) Install(cfg config.HomebrewConfig) error {
	if !h.IsInstalled() {
		return fmt.Errorf("Homebrew is not installed. Please install it first: /bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"")
	}

	// Add taps
	for _, tap := range cfg.Taps {
		if err := h.addTap(tap); err != nil {
			return fmt.Errorf("failed to add tap %s: %w", tap, err)
		}
	}

	// Install brews
	for _, brew := range cfg.Brews {
		if err := h.installBrew(brew); err != nil {
			return fmt.Errorf("failed to install brew %s: %w", brew, err)
		}
	}

	// Install casks
	for _, cask := range cfg.Casks {
		if err := h.installCask(cask); err != nil {
			return fmt.Errorf("failed to install cask %s: %w", cask, err)
		}
	}

	return nil
}

func (h *HomebrewManager) addTap(tap string) error {
	if h.verbose {
		fmt.Printf("Adding Homebrew tap: %s\n", tap)
	}

	cmd := exec.Command("brew", "tap", tap)
	output, err := cmd.CombinedOutput()
	if err != nil {
		// Check if tap is already added
		if strings.Contains(string(output), "already tapped") {
			if h.verbose {
				fmt.Printf("Tap %s already exists\n", tap)
			}
			return nil
		}
		return fmt.Errorf("brew tap failed: %s", string(output))
	}

	return nil
}

func (h *HomebrewManager) installBrew(brew string) error {
	// Check if already installed
	if h.isBrewInstalled(brew) {
		if h.verbose {
			fmt.Printf("Brew %s already installed\n", brew)
		}
		return nil
	}

	if h.verbose {
		fmt.Printf("Installing Homebrew formula: %s\n", brew)
	}

	cmd := exec.Command("brew", "install", brew)
	output, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("brew install failed: %s", string(output))
	}

	return nil
}

func (h *HomebrewManager) installCask(cask string) error {
	// Check if already installed
	if h.isCaskInstalled(cask) {
		if h.verbose {
			fmt.Printf("Cask %s already installed\n", cask)
		}
		return nil
	}

	if h.verbose {
		fmt.Printf("Installing Homebrew cask: %s\n", cask)
	}

	cmd := exec.Command("brew", "install", "--cask", cask)
	output, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("brew cask install failed: %s", string(output))
	}

	return nil
}

func (h *HomebrewManager) IsBrewInstalled(brew string) bool {
	cmd := exec.Command("brew", "list", brew)
	err := cmd.Run()
	return err == nil
}

func (h *HomebrewManager) IsCaskInstalled(cask string) bool {
	cmd := exec.Command("brew", "list", "--cask", cask)
	err := cmd.Run()
	return err == nil
}

// Keep private versions for internal use
func (h *HomebrewManager) isBrewInstalled(brew string) bool {
	return h.IsBrewInstalled(brew)
}

func (h *HomebrewManager) isCaskInstalled(cask string) bool {
	return h.IsCaskInstalled(cask)
}