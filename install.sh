#!/bin/bash

# Dotfiles v2 Bootstrap Script
# Complete bootstrap from scratch for macOS

set -euo pipefail

DOTFILES_DIR="${HOME}/.dotfiles"
DOTFILES_BINARY="${DOTFILES_DIR}/dotfiles"
BIN_DIR="${HOME}/.bin"
INSTALLED_BINARY="${BIN_DIR}/dotfiles"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[DOTFILES]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Check if we're in the dotfiles directory
if [[ ! -f "${DOTFILES_DIR}/config.yaml" ]]; then
    error "This script must be run from ${DOTFILES_DIR}"
fi

cd "${DOTFILES_DIR}"

# Install Homebrew if not present
if ! command -v brew >/dev/null 2>&1; then
    log "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for current session
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        # Apple Silicon Mac
        eval "$(/opt/homebrew/bin/brew shellenv)"
        log "Added Homebrew to PATH (Apple Silicon)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        # Intel Mac
        eval "$(/usr/local/bin/brew shellenv)"
        log "Added Homebrew to PATH (Intel)"
    fi
    
    success "Homebrew installed successfully"
else
    log "Homebrew already installed"
fi

# Install Go if not present
if ! command -v go >/dev/null 2>&1; then
    log "Go not found. Installing Go via Homebrew..."
    brew install go
    success "Go installed successfully"
else
    log "Go already installed ($(go version))"
fi

# Create ~/.bin directory if it doesn't exist
if [[ ! -d "${BIN_DIR}" ]]; then
    log "Creating ${BIN_DIR} directory..."
    mkdir -p "${BIN_DIR}"
    success "Created ${BIN_DIR}"
fi

# Build the dotfiles manager if needed or if source has changed
build_needed=false
if [[ ! -f "${DOTFILES_BINARY}" ]]; then
    build_needed=true
    log "Dotfiles binary not found, building..."
elif [[ "${DOTFILES_BINARY}" -ot "main.go" ]]; then
    build_needed=true
    log "Source newer than binary, rebuilding..."
elif find cmd internal -newer "${DOTFILES_BINARY}" -print -quit 2>/dev/null | grep -q .; then
    build_needed=true
    log "Source files updated, rebuilding..."
fi

if [[ "$build_needed" == "true" ]]; then
    log "Building dotfiles manager..."
    go build -o dotfiles
    success "Dotfiles manager built successfully"
else
    log "Dotfiles manager is up to date"
fi

# Make the binary executable
chmod +x "${DOTFILES_BINARY}"

# Copy binary to ~/.bin if it's different or doesn't exist
if [[ ! -f "${INSTALLED_BINARY}" ]] || ! cmp -s "${DOTFILES_BINARY}" "${INSTALLED_BINARY}"; then
    log "Installing dotfiles binary to ${BIN_DIR}..."
    cp "${DOTFILES_BINARY}" "${INSTALLED_BINARY}"
    chmod +x "${INSTALLED_BINARY}"
    success "Dotfiles binary installed to ${INSTALLED_BINARY}"
else
    log "Dotfiles binary in ${BIN_DIR} is up to date"
fi

# Check if ~/.bin is in PATH
if [[ ":$PATH:" != *":${BIN_DIR}:"* ]]; then
    warn "⚠️  ${BIN_DIR} is not in your PATH!"
    warn "Add this to your shell config:"
    warn "  export PATH=\"${BIN_DIR}:\$PATH\""
    warn ""
    warn "Or run directly: ${INSTALLED_BINARY}"
else
    success "✅ ${BIN_DIR} is in your PATH"
fi

# Run the update using the installed binary
log "Starting dotfiles update..."
"${INSTALLED_BINARY}" update "$@"

success "🎉 Bootstrap complete!"
success "✅ Homebrew installed and configured"
success "✅ Go installed and ready"
success "✅ Dotfiles manager built and installed to ${INSTALLED_BINARY}"
success ""
success "You can now use 'dotfiles' from anywhere (if ~/.bin is in PATH)"
success "Or run directly: ${INSTALLED_BINARY}"