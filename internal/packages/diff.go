package packages

import (
	"fmt"
	"os/exec"
	"strings"

	"dotfiles/internal/config"
)

// PackageDiff represents packages that would be installed/updated
type PackageDiff struct {
	NewTaps   []string
	NewBrews  []string
	NewCasks  []string
	HasChanges bool
}

// GetPackageDiff returns what packages would be installed
func (h *HomebrewManager) GetPackageDiff(cfg config.HomebrewConfig) (*PackageDiff, error) {
	if !h.IsInstalled() {
		return &PackageDiff{
			NewTaps:   cfg.Taps,
			NewBrews:  cfg.Brews,
			NewCasks:  cfg.Casks,
			HasChanges: len(cfg.Taps) > 0 || len(cfg.Brews) > 0 || len(cfg.Casks) > 0,
		}, nil
	}

	diff := &PackageDiff{}

	// Check taps
	for _, tap := range cfg.Taps {
		if !h.isTapInstalled(tap) {
			diff.NewTaps = append(diff.NewTaps, tap)
		}
	}

	// Check brews
	for _, brew := range cfg.Brews {
		if !h.isBrewInstalled(brew) {
			diff.NewBrews = append(diff.NewBrews, brew)
		}
	}

	// Check casks
	for _, cask := range cfg.Casks {
		if !h.isCaskInstalled(cask) {
			diff.NewCasks = append(diff.NewCasks, cask)
		}
	}

	diff.HasChanges = len(diff.NewTaps) > 0 || len(diff.NewBrews) > 0 || len(diff.NewCasks) > 0

	return diff, nil
}

// PrintDiff prints a user-friendly package diff
func (d *PackageDiff) PrintDiff(homebrewInstalled bool) {
	if !homebrewInstalled {
		fmt.Println("  ⚠️  Homebrew not installed - packages will be skipped")
		if len(d.NewTaps) > 0 || len(d.NewBrews) > 0 || len(d.NewCasks) > 0 {
			fmt.Println("  📦 Would install once Homebrew is available:")
			if len(d.NewTaps) > 0 {
				fmt.Printf("    Taps: %v\n", d.NewTaps)
			}
			if len(d.NewBrews) > 0 {
				fmt.Printf("    Brews: %v\n", d.NewBrews)
			}
			if len(d.NewCasks) > 0 {
				fmt.Printf("    Casks: %v\n", d.NewCasks)
			}
		}
		return
	}

	if !d.HasChanges {
		fmt.Println("  ✅ All packages already installed")
		return
	}

	if len(d.NewTaps) > 0 {
		fmt.Println("  📝 NEW TAPS:")
		for _, tap := range d.NewTaps {
			fmt.Printf("    + %s\n", tap)
		}
	}

	if len(d.NewBrews) > 0 {
		fmt.Println("  📝 NEW BREWS:")
		for _, brew := range d.NewBrews {
			fmt.Printf("    + %s\n", brew)
		}
	}

	if len(d.NewCasks) > 0 {
		fmt.Println("  📝 NEW CASKS:")
		for _, cask := range d.NewCasks {
			fmt.Printf("    + %s\n", cask)
		}
	}
}

func (h *HomebrewManager) isTapInstalled(tap string) bool {
	cmd := exec.Command("brew", "tap")
	output, err := cmd.Output()
	if err != nil {
		return false
	}

	taps := string(output)
	return strings.Contains(taps, tap)
}

// Helper function to check if tap is in the list
func contains(slice []string, item string) bool {
	for _, s := range slice {
		if s == item {
			return true
		}
	}
	return false
}