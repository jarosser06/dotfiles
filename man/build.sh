#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/src"

if ! command -v pandoc &>/dev/null; then
  echo "Error: pandoc not found. Install with: brew install pandoc"
  exit 1
fi

count=0
for src in "$SRC_DIR"/*.md; do
  [ -f "$src" ] || continue
  name="$(basename "$src" .md)"
  # Extract section number from filename (e.g., dot.1.md → 1, dot-vim.7.md → 7)
  section="${name##*.}"
  out_dir="$SCRIPT_DIR/man${section}"
  mkdir -p "$out_dir"
  pandoc -s -t man "$src" -o "$out_dir/$name"
  count=$((count + 1))
done

echo "Built $count man pages in $SCRIPT_DIR"
