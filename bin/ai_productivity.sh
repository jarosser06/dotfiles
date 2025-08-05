#!/bin/bash

# AI Productivity Framework Setup Script
# Simplified installation for Claude + MCP + Local Models

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
SKIP_API_SETUP=false
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
    
    print_status "Installing @miottid/todoist-mcp..."
    # Try Smithery first, fallback to manual installation
    if npx -y @smithery/cli install @miottid/todoist-mcp --client claude 2>/dev/null; then
        print_status "Todoist MCP installed via Smithery"
    else
        print_warning "Smithery installation failed, installing manually..."
        TODOIST_MCP_DIR="$INSTALL_DIR/todoist-mcp"
        if [[ ! -d "$TODOIST_MCP_DIR" ]]; then
            git clone https://github.com/Doist/todoist-mcp.git "$TODOIST_MCP_DIR"
            cd "$TODOIST_MCP_DIR"
            npm install
            npm run build
            cd - > /dev/null
            print_status "Todoist MCP built from source"
        else
            print_status "Todoist MCP already exists"
        fi
    fi
    
    print_status "Installing @modelcontextprotocol/server-brave-search..."
    npm install -g "@modelcontextprotocol/server-brave-search" || print_warning "Failed to install brave-search server"
    
    print_status "Installing @modelcontextprotocol/server-memory..."
    npm install -g "@modelcontextprotocol/server-memory" || print_warning "Failed to install memory server"
    
    print_status "Installing @executeautomation/playwright-mcp-server..."
    npm install -g "@executeautomation/playwright-mcp-server" || print_warning "Failed to install playwright server"
    
    # Install doobidoo's memory service using git + uv
    print_status "Installing doobidoo/mcp-memory-service..."
    MEMORY_SERVICE_DIR="$INSTALL_DIR/mcp-memory-service"
    if [[ ! -d "$MEMORY_SERVICE_DIR" ]]; then
        git clone https://github.com/doobidoo/mcp-memory-service.git "$MEMORY_SERVICE_DIR"
        cd "$MEMORY_SERVICE_DIR"
        python install.py --skip-multi-client-prompt --skip-claude-commands-prompt || print_warning "Failed to install doobidoo memory service"
        cd - > /dev/null
    else
        print_status "doobidoo/mcp-memory-service already exists"
    fi
    
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
    "doobidoo-memory": {
      "command": "uv",
      "args": ["--directory", "~/Documents/ai-productivity/mcp-memory-service", "run", "memory"],
      "env": {
        "MCP_MEMORY_CHROMA_PATH": "~/Documents/ai-productivity/memory/chroma_db",
        "MCP_MEMORY_BACKUPS_PATH": "~/Documents/ai-productivity/memory/backups",
        "MCP_MEMORY_STORAGE_BACKEND": "sqlite_vec",
        "MCP_MEMORY_SQLITE_PATH": "~/Documents/ai-productivity/memory/sqlite_vec.db"
      }
    },
    "playwright": {
      "command": "npx",
      "args": ["-y", "@executeautomation/playwright-mcp-server"],
      "env": {}
    },
    "todoist": {
      "command": "node",
      "args": ["~/Documents/ai-productivity/todoist-mcp/build/index.js"],
      "env": {
        "TODOIST_API_KEY": "${TODOIST_API_KEY}"
      }
    },
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "${BRAVE_API_KEY}"
      }
    }
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

# Function to setup API key template
setup_api_key_template() {
    if [[ $SKIP_API_SETUP == true ]]; then
        print_warning "Skipping API setup as requested"
        return
    fi
    
    print_section "Creating API Key Setup Template"
    
    cat > "$HOME/.local/bin/setup-api-keys.sh" << 'EOF'
#!/bin/bash
echo "🔐 API Key Setup Guide"
echo ""
echo "You'll need to get API keys for the following services:"
echo ""
echo "1. Brave Search API"
echo "   - Visit: https://api.search.brave.com/"
echo "   - Sign up and get your API key"
echo "   - Add to your shell config: export BRAVE_API_KEY='your_key_here'"
echo ""
echo "2. Todoist API Token"
echo "   - Visit: https://app.todoist.com/app/settings/integrations/developer"
echo "   - Copy your API token"
echo "   - Add to your shell config: export TODOIST_API_KEY='your_token_here'"
echo ""
echo "3. Notion Integration"
echo "   - Visit: https://mcp.notion.com"
echo "   - Follow the OAuth setup instructions"
echo ""
echo "After setting up API keys, restart Claude Desktop for changes to take effect."
EOF

    chmod +x "$HOME/.local/bin/setup-api-keys.sh"
    print_status "API key setup guide created"
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
    
    # Check scripts
    if [[ ! -x "$HOME/.local/bin/ai-morning-routine.sh" ]]; then
        print_error "Morning routine script not executable"
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
    
    echo -e "${GREEN}🎉 AI Productivity Framework installation completed!${NC}\n"
    
    echo "Next steps:"
    echo "1. Start Ollama: ollama serve"
    echo "2. Set up API keys: ~/.local/bin/setup-api-keys.sh"
    echo "3. Configure Notion integration: https://mcp.notion.com"
    echo "4. Restart Claude Desktop to load MCP servers"
    echo "5. Test by asking Claude: 'What MCP servers are available?'"
    
    echo -e "\n${BLUE}Available scripts:${NC}"
    echo "- setup-api-keys.sh: API key setup guide"
    
    echo -e "\n${BLUE}MCP Servers installed:${NC}"
    echo "- filesystem: File system access and management"
    echo "- memory: Basic persistent AI memory storage"
    echo "- doobidoo-memory: Advanced semantic memory with consolidation"
    echo "- playwright: Browser automation"
    echo "- todoist: Task management"
    echo "- brave-search: Web research"
    
    echo -e "\n${YELLOW}Important:${NC}"
    echo "- Backup created at: $BACKUP_DIR"
    echo "- Configuration files in: $CLAUDE_CONFIG_DIR"
    echo "- AI productivity data in: $INSTALL_DIR"
    echo "- Run setup-api-keys.sh to configure external services"
    
    echo -e "\n${GREEN}Happy productivity! 🚀${NC}"
}

# Function to show usage
show_usage() {
    echo "AI Productivity Framework Setup Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -s, --skip-api          Skip API key setup"
    echo "  -v, --verbose           Verbose output"
    echo "  -y, --yes               Non-interactive mode (auto-confirm)"
    echo "  -h, --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                      Basic installation"
    echo "  $0 --skip-api           Installation without API setup"
}

# Main installation function
main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -s|--skip-api)
                SKIP_API_SETUP=true
                shift
                ;;
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
    echo "║              AI Productivity Framework Setup                 ║"
    echo "║     Claude + MCP + Local Models (Prerequisites: Homebrew,   ║"
    echo "║              Node.js, Colima/Docker already installed)      ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo "Configuration:"
    echo "- Skip API setup: $SKIP_API_SETUP"
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
    setup_api_key_template
    verify_installation
    show_post_install_instructions
}

# Run main function with all arguments
main "$@"
