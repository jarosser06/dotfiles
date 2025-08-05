#!/bin/bash

# MCP Server Setup Script
# Installs and configures MCP servers for Claude Desktop

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
INSTALL_DIR="$HOME/Documents/ai-productivity"
CLAUDE_CONFIG_DIR="$HOME/Library/Application Support/Claude"
BACKUP_DIR="$HOME/.ai-productivity-backup-$(date +%Y%m%d-%H%M%S)"

# Flags
VERBOSE=false
NON_INTERACTIVE=false

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_section() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to backup existing configurations
backup_existing_configs() {
    print_section "Creating Backup of Existing Configurations"
    
    mkdir -p "$BACKUP_DIR"
    
    # Backup Claude Desktop config if it exists
    if [[ -f "$CLAUDE_CONFIG_DIR/claude_desktop_config.json" ]]; then
        cp "$CLAUDE_CONFIG_DIR/claude_desktop_config.json" "$BACKUP_DIR/"
        print_status "Backed up Claude Desktop configuration"
    fi
    
    # Backup shell configurations
    for config in ~/.zshrc ~/.bashrc ~/.bash_profile; do
        if [[ -f "$config" ]]; then
            cp "$config" "$BACKUP_DIR/"
            print_status "Backed up $(basename $config)"
        fi
    done
    
    print_status "Backup created at: $BACKUP_DIR"
}

# Function to detect shell and get config file
get_shell_config() {
    case "$SHELL" in
        */zsh)
            echo "$HOME/.zshrc"
            ;;
        */bash)
            if [[ -f "$HOME/.bashrc" ]]; then
                echo "$HOME/.bashrc"
            else
                echo "$HOME/.bash_profile"
            fi
            ;;
        *)
            echo "$HOME/.profile"
            ;;
    esac
}

# Function to ensure colima is running for docker
ensure_colima_running() {
    if command_exists colima; then
        print_section "Ensuring Colima is Running"
        
        if ! colima status >/dev/null 2>&1; then
            print_status "Starting Colima..."
            colima start
            print_status "Colima started successfully"
        else
            print_status "Colima is already running"
        fi
    elif command_exists docker; then
        print_status "Docker is available (not using Colima)"
    else
        print_warning "Neither Colima nor Docker found - Docker features may not work"
    fi
}

# Function to install Ollama
install_ollama() {
    if ! command_exists ollama; then
        print_section "Installing Ollama"
        
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS installation - download and install the DMG
            print_status "Installing Ollama on macOS..."
            
            # Download the macOS DMG
            OLLAMA_URL="https://ollama.com/download/Ollama.dmg"
            TEMP_DIR=$(mktemp -d)
            
            print_status "Downloading Ollama for macOS..."
            curl -L "$OLLAMA_URL" -o "$TEMP_DIR/Ollama.dmg"
            
            print_status "Mounting DMG and installing Ollama..."
            # Mount the DMG
            MOUNT_POINT=$(hdiutil attach "$TEMP_DIR/Ollama.dmg" -nobrowse | grep -o '/Volumes/.*')
            
            if [[ -d "$MOUNT_POINT/Ollama.app" ]]; then
                # Copy app to Applications
                cp -R "$MOUNT_POINT/Ollama.app" /Applications/
                print_status "Ollama.app installed to /Applications/"
                
                # Unmount the DMG
                hdiutil detach "$MOUNT_POINT" -quiet
                
                # Create command line symlink
                sudo ln -sf /Applications/Ollama.app/Contents/Resources/ollama /usr/local/bin/ollama
                print_status "Command line tool linked to /usr/local/bin/ollama"
            else
                print_error "Failed to find Ollama.app in DMG"
                hdiutil detach "$MOUNT_POINT" -quiet 2>/dev/null || true
                exit 1
            fi
            
            # Cleanup
            rm -rf "$TEMP_DIR"
            print_status "Ollama installed successfully on macOS"
            
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # Linux installation using official script
            print_status "Installing Ollama on Linux..."
            curl -fsSL https://ollama.ai/install.sh | sh
            print_status "Ollama installed successfully"
        else
            print_error "Unsupported operating system: $OSTYPE"
            print_status "Please install Ollama manually from https://ollama.ai"
            exit 1
        fi
    else
        print_status "Ollama is already installed"
    fi
}

# Function to install MCP servers
install_mcp_servers() {
    print_section "Installing MCP Servers"
    
    # Install uv if not available
    if ! command_exists uv; then
        print_status "Installing uv package manager..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        export PATH="$HOME/.local/bin:$PATH"
    fi
    
    # Install MCP servers using different methods
    print_status "Installing @modelcontextprotocol/server-filesystem..."
    npm install -g "@modelcontextprotocol/server-filesystem" || print_warning "Failed to install filesystem server"
    
    
    
    print_status "Installing @modelcontextprotocol/server-memory..."
    npm install -g "@modelcontextprotocol/server-memory" || print_warning "Failed to install memory server"
    
    print_status "Installing @executeautomation/playwright-mcp-server..."
    npm install -g "@executeautomation/playwright-mcp-server" || print_warning "Failed to install playwright server"
    
    
    print_status "MCP servers installation complete"
}

# Function to create directory structure
create_directory_structure() {
    print_section "Creating Directory Structure"
    
    mkdir -p "$INSTALL_DIR"/{memory,conversations,exports,automation,projects}
    mkdir -p "$INSTALL_DIR/memory"/{chroma_db,backups}
    mkdir -p "$CLAUDE_CONFIG_DIR"
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/.claude"
    mkdir -p "$HOME/diagrams"
    
    print_status "Directory structure created at: $INSTALL_DIR"
}

# Function to setup Claude Desktop MCP configuration
setup_claude_mcp_config() {
    print_section "Setting up Claude Desktop MCP Configuration"
    
    local config_file="$CLAUDE_CONFIG_DIR/claude_desktop_config.json"
    
    cat > "$config_file" << 'EOF'
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/Users"],
      "env": {}
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"],
      "env": {}
    },
    "playwright": {
      "command": "npx",
      "args": ["-y", "@executeautomation/playwright-mcp-server"],
      "env": {}
    },
  }
}
EOF

    print_status "Claude Desktop MCP configuration created"
}

# Function to setup Ollama models
setup_ollama_models() {
    print_section "Setting up Ollama Local Models"
    
    print_status "Starting Ollama service..."
    ollama serve &
    sleep 5
    
    # Pull recommended models
    local models=(
        "qwen2.5:14b"
        "llama3.2:3b"
        "codellama:13b"
    )
    
    for model in "${models[@]}"; do
        print_status "Pulling model: $model"
        ollama pull "$model" || print_warning "Failed to pull $model - continuing with other models"
    done
    
    print_status "Ollama models setup complete"
}


# Function to verify installation
verify_installation() {
    print_section "Verifying Installation"
    
    local errors=0
    
    # Check directories
    if [[ ! -d "$INSTALL_DIR" ]]; then
        print_error "AI productivity directory not created"
        ((errors++))
    fi
    
    # Check Claude config
    if [[ ! -f "$CLAUDE_CONFIG_DIR/claude_desktop_config.json" ]]; then
        print_error "Claude Desktop configuration not found"
        ((errors++))
    fi
    
    # Check Ollama
    if ! command_exists ollama; then
        print_error "Ollama not installed"
        ((errors++))
    fi
    
    
    if [[ $errors -eq 0 ]]; then
        print_status "✅ Installation verification completed successfully!"
    else
        print_error "❌ Installation verification found $errors error(s)"
        return 1
    fi
}

# Function to display post-installation instructions
show_post_install_instructions() {
    print_section "Post-Installation Instructions"
    
    echo -e "${GREEN}🎉 MCP Server setup completed!${NC}\n"
    
    echo "Next steps:"
    echo "1. Start Ollama: ollama serve"
    echo "2. Restart Claude Desktop to load MCP servers"
    echo "3. Test by asking Claude: 'What MCP servers are available?'"
    
    
    echo -e "\n${BLUE}MCP Servers installed:${NC}"
    echo "- filesystem: File system access and management"
    echo "- memory: Basic persistent AI memory storage"
    echo "- playwright: Browser automation"
    
    echo -e "\n${YELLOW}Important:${NC}"
    echo "- Backup created at: $BACKUP_DIR"
    echo "- Configuration files in: $CLAUDE_CONFIG_DIR"
    echo "- MCP server data in: $INSTALL_DIR"
    
    echo -e "\n${GREEN}Happy productivity! 🚀${NC}"
}

# Function to show usage
show_usage() {
    echo "MCP Server Setup Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo ""
    echo "  -v, --verbose           Verbose output"
    echo "  -y, --yes               Non-interactive mode (auto-confirm)"
    echo "  -h, --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                      Basic installation"
    echo ""
}

# Main installation function
main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -y|--yes)
                NON_INTERACTIVE=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    MCP Server Setup                         ║"
    echo "║     Installs MCP servers for Claude Desktop (Prerequisites: ║"
    echo "║              Node.js, Homebrew already installed)           ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo "Configuration:"
    echo "- Verbose: $VERBOSE"
    echo "- Non-interactive: $NON_INTERACTIVE"
    echo ""
    
    if [[ $NON_INTERACTIVE == false ]]; then
        read -p "Continue with installation? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Installation cancelled."
            exit 0
        fi
    else
        echo "Non-interactive mode: proceeding with installation..."
    fi
    
    # Check prerequisites
    if ! command_exists node; then
        print_error "Node.js is required but not found. Please install it first."
        exit 1
    fi
    
    if ! command_exists brew && [[ "$OSTYPE" == "darwin"* ]]; then
        print_error "Homebrew is required but not found. Please install it first."
        exit 1
    fi
    
    # Run installation steps
    ensure_colima_running
    install_ollama
    install_mcp_servers
    create_directory_structure
    setup_claude_mcp_config
    setup_ollama_models
    verify_installation
    show_post_install_instructions
}

# Run main function with all arguments
main "$@"
