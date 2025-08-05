package files

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

// DiffResult represents the result of comparing two files
type DiffResult struct {
	SourcePath string
	DestPath   string
	Status     DiffStatus
	Changes    []string
}

// DiffStatus represents the type of difference
type DiffStatus int

const (
	DiffNew DiffStatus = iota
	DiffModified
	DiffIdentical
	DiffDestMissing
	DiffSourceMissing
)

func (d DiffStatus) String() string {
	switch d {
	case DiffNew:
		return "NEW"
	case DiffModified:
		return "MODIFIED"
	case DiffIdentical:
		return "IDENTICAL"
	case DiffDestMissing:
		return "DEST_MISSING"
	case DiffSourceMissing:
		return "SOURCE_MISSING"
	default:
		return "UNKNOWN"
	}
}

// CompareFiles compares source and destination files and returns diff information
func (m *Mapper) CompareFiles(sourcePath, destPath string) (*DiffResult, error) {
	result := &DiffResult{
		SourcePath: sourcePath,
		DestPath:   destPath,
	}

	// Check if source exists
	if _, err := os.Stat(sourcePath); os.IsNotExist(err) {
		result.Status = DiffSourceMissing
		return result, nil
	}

	// Check if destination exists
	destInfo, err := os.Lstat(destPath)
	if os.IsNotExist(err) {
		result.Status = DiffNew
		return result, nil
	}

	// If destination is a symlink, check what it points to
	if destInfo.Mode()&os.ModeSymlink != 0 {
		target, err := os.Readlink(destPath)
		if err != nil {
			return nil, fmt.Errorf("failed to read symlink %s: %w", destPath, err)
		}
		
		if target == sourcePath {
			result.Status = DiffIdentical
			return result, nil
		} else {
			result.Status = DiffModified
			result.Changes = []string{fmt.Sprintf("Symlink target: %s → %s", target, sourcePath)}
			return result, nil
		}
	}

	// Compare file contents
	identical, changes, err := compareFileContents(sourcePath, destPath)
	if err != nil {
		return nil, fmt.Errorf("failed to compare files: %w", err)
	}

	if identical {
		result.Status = DiffIdentical
	} else {
		result.Status = DiffModified
		result.Changes = changes
	}

	return result, nil
}

// compareFileContents compares the contents of two files
func compareFileContents(file1, file2 string) (bool, []string, error) {
	f1, err := os.Open(file1)
	if err != nil {
		return false, nil, err
	}
	defer f1.Close()

	f2, err := os.Open(file2)
	if err != nil {
		return false, nil, err
	}
	defer f2.Close()

	scanner1 := bufio.NewScanner(f1)
	scanner2 := bufio.NewScanner(f2)

	var changes []string
	lineNum := 1
	identical := true

	for {
		has1 := scanner1.Scan()
		has2 := scanner2.Scan()

		if !has1 && !has2 {
			break // Both files ended
		}

		if !has1 {
			// File1 ended, file2 has more lines
			changes = append(changes, fmt.Sprintf("+ %d: %s", lineNum, scanner2.Text()))
			identical = false
			lineNum++
			continue
		}

		if !has2 {
			// File2 ended, file1 has more lines
			changes = append(changes, fmt.Sprintf("- %d: %s", lineNum, scanner1.Text()))
			identical = false
			lineNum++
			continue
		}

		line1 := scanner1.Text()
		line2 := scanner2.Text()

		if line1 != line2 {
			changes = append(changes, fmt.Sprintf("- %d: %s", lineNum, line2))
			changes = append(changes, fmt.Sprintf("+ %d: %s", lineNum, line1))
			identical = false
		}

		lineNum++
	}

	// Limit changes to first 10 differences to avoid overwhelming output
	if len(changes) > 20 {
		changes = changes[:20]
		changes = append(changes, "... (showing first 10 differences)")
	}

	return identical, changes, nil
}

// PrintDiff prints a user-friendly diff output
func (d *DiffResult) PrintDiff() {
	switch d.Status {
	case DiffNew:
		fmt.Printf("📄 NEW: %s → %s\n", d.SourcePath, d.DestPath)
	case DiffModified:
		fmt.Printf("📝 MODIFIED: %s → %s\n", d.SourcePath, d.DestPath)
		if len(d.Changes) > 0 {
			for _, change := range d.Changes {
				if strings.HasPrefix(change, "+") {
					fmt.Printf("  \033[32m%s\033[0m\n", change) // Green for additions
				} else if strings.HasPrefix(change, "-") {
					fmt.Printf("  \033[31m%s\033[0m\n", change) // Red for deletions
				} else {
					fmt.Printf("  %s\n", change)
				}
			}
		}
	case DiffIdentical:
		fmt.Printf("✅ IDENTICAL: %s → %s\n", d.SourcePath, d.DestPath)
	case DiffSourceMissing:
		fmt.Printf("❌ SOURCE MISSING: %s\n", d.SourcePath)
	case DiffDestMissing:
		fmt.Printf("📄 NEW: %s → %s (destination missing)\n", d.SourcePath, d.DestPath)
	}
}