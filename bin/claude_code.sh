#!/bin/bash

# Claude Code Installation Script with MCP Servers
# This script installs Claude Code and sets up Playwright and Serena MCP servers

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Node.js is installed
check_node() {
    log_info "Checking Node.js installation..."
    
    if ! command -v node &> /dev/null; then
        log_error "Node.js is not installed!"
        log_error "Please install Node.js using Homebrew:"
        log_error "  brew install node"
        exit 1
    fi
    
    NODE_VERSION=$(node --version)
    log_success "Node.js found: $NODE_VERSION"
    
    # Check if version is 18+
    NODE_MAJOR_VERSION=$(echo $NODE_VERSION | sed 's/v//' | cut -d. -f1)
    if [ "$NODE_MAJOR_VERSION" -lt 18 ]; then
        log_error "Node.js version 18+ is required. Current version: $NODE_VERSION"
        log_error "Please update Node.js using Homebrew:"
        log_error "  brew upgrade node"
        exit 1
    fi
    
    log_success "Node.js version is compatible (18+)"
}

# Check if npm is available
check_npm() {
    log_info "Checking npm availability..."
    
    if ! command -v npm &> /dev/null; then
        log_error "npm is not available!"
        log_error "npm should come bundled with Node.js. Please reinstall Node.js:"
        log_error "  brew reinstall node"
        exit 1
    fi
    
    NPM_VERSION=$(npm --version)
    log_success "npm found: $NPM_VERSION"
}

# Install Claude Code
install_claude_code() {
    log_info "Installing Claude Code..."
    
    # Check if Claude Code is already installed
    if command -v claude &> /dev/null; then
        log_warning "Claude Code is already installed. Checking version..."
        CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "unknown")
        log_info "Current Claude Code version: $CLAUDE_VERSION"
        
        read -p "Do you want to reinstall/update Claude Code? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Skipping Claude Code installation"
            return 0
        fi
    fi
    
    # Install using the official installer script (recommended method)
    log_info "Downloading and running Claude Code installer..."
    curl -fsSL https://claude.ai/install.sh | bash
    
    # Verify installation
    if command -v claude &> /dev/null; then
        CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "installed")
        log_success "Claude Code installed successfully: $CLAUDE_VERSION"
        
        # Run claude doctor to check installation
        log_info "Running claude doctor to verify installation..."
        claude doctor || log_warning "claude doctor reported some issues, but installation may still work"
    else
        log_error "Claude Code installation failed!"
        exit 1
    fi
}

# Check if uv is available (needed for Serena)
check_uv() {
    log_info "Checking if uv is installed (required for Serena)..."
    
    if ! command -v uv &> /dev/null; then
        log_warning "uv is not installed. Installing uv..."
        
        # Install uv using the official installer
        curl -LsSf https://astral.sh/uv/install.sh | sh
        
        # Source the shell profile to make uv available
        if [ -f "$HOME/.cargo/env" ]; then
            source "$HOME/.cargo/env"
        fi
        
        # Try to reload PATH
        export PATH="$HOME/.cargo/bin:$PATH"
        
        if ! command -v uv &> /dev/null; then
            log_error "Failed to install uv. Please install manually:"
            log_error "  curl -LsSf https://astral.sh/uv/install.sh | sh"
            log_error "Then restart your shell or run: source ~/.cargo/env"
            exit 1
        fi
    fi
    
    UV_VERSION=$(uv --version)
    log_success "uv found: $UV_VERSION"
}

# Install Playwright MCP server
install_playwright_mcp() {
    log_info "Installing Playwright MCP server..."
    
    # Install the official Microsoft Playwright MCP
    npm install -g @playwright/mcp
    
    if [ $? -eq 0 ]; then
        log_success "Playwright MCP server installed successfully"
    else
        log_error "Failed to install Playwright MCP server"
        return 1
    fi
}

# Setup MCP servers with Claude Code
setup_mcp_servers() {
    log_info "Setting up MCP servers with Claude Code..."
    
    # Check if we're in a git repository or project directory
    if [ ! -d "$(pwd)/.git" ] && [ ! -f "$(pwd)/package.json" ] && [ ! -f "$(pwd)/pyproject.toml" ] && [ ! -f "$(pwd)/Cargo.toml" ]; then
        log_warning "You're not in a project directory. MCP servers will be configured for the current directory."
        log_warning "For best results, run this from your project root directory."
    fi
    
    CURRENT_DIR=$(pwd)
    
    # Add Playwright MCP server
    log_info "Adding Playwright MCP server to Claude Code..."
    claude mcp add playwright -- npx @playwright/mcp@latest --project "$CURRENT_DIR"
    
    if [ $? -eq 0 ]; then
        log_success "Playwright MCP server added to Claude Code"
    else
        log_warning "Failed to add Playwright MCP server to Claude Code"
    fi
    
    # Add Serena MCP server
    log_info "Adding Serena MCP server to Claude Code..."
    claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena-mcp-server --context ide-assistant --project "$CURRENT_DIR"
    
    if [ $? -eq 0 ]; then
        log_success "Serena MCP server added to Claude Code"
    else
        log_warning "Failed to add Serena MCP server to Claude Code"
    fi
}

# Main installation function
main() {
    log_info "Starting Claude Code installation with MCP servers..."
    echo
    
    # Step 1: Check prerequisites
    check_node
    check_npm
    echo
    
    # Step 2: Install Claude Code
    install_claude_code
    echo
    
    # Step 3: Check/install uv for Serena
    check_uv
    echo
    
    # Step 4: Install Playwright MCP
    install_playwright_mcp
    echo
    
    # Step 5: Setup MCP servers
    setup_mcp_servers
    echo
    
    # Final instructions
    log_success "Installation completed!"
    echo
    log_info "Next steps:"
    echo "1. Navigate to your project directory"
    echo "2. Run 'claude' to start Claude Code"
    echo "3. On first run, you'll need to authenticate with your Anthropic account"
    echo "4. To use Serena, run: /mcp__serena__initial_instructions"
    echo "5. To use Playwright, say: 'Use playwright mcp to open a browser'"
    echo
    log_info "Available MCP commands:"
    echo "• /mcp - List all available MCP servers and tools"
    echo "• /mcp__serena__initial_instructions - Load Serena instructions"
    echo
    log_info "For more information:"
    echo "• Claude Code docs: https://docs.anthropic.com/en/docs/claude-code"
    echo "• Playwright MCP: https://github.com/microsoft/playwright-mcp"
    echo "• Serena: https://github.com/oraios/serena"
    echo
    log_warning "Note: This script configured MCP servers for the current directory: $CURRENT_DIR"
    log_warning "To use MCP servers in other projects, run 'claude mcp add ...' in those directories"
}

# Run the main function
main "$@"