#!/bin/bash

# Colima Setup Script for macOS
# Installs and configures Colima (container runtime) with Docker CLI

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
COLIMA_PROFILE="default"
COLIMA_CPU=2
COLIMA_MEMORY=4
COLIMA_DISK=60

# Flags
VERBOSE=false
START_AFTER_INSTALL=true

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

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
    -h, --help              Show this help message
    -v, --verbose           Enable verbose output
    --no-start              Don't start Colima after installation
    --cpu CORES             Set CPU cores for Colima VM (default: 2)
    --memory GB             Set memory in GB for Colima VM (default: 4)
    --disk GB               Set disk size in GB for Colima VM (default: 60)
    --profile NAME          Set Colima profile name (default: default)

Examples:
    $0                      # Install with default settings
    $0 --cpu 4 --memory 8   # Install with 4 CPU cores and 8GB memory
    $0 --no-start           # Install but don't start Colima
EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            --no-start)
                START_AFTER_INSTALL=false
                shift
                ;;
            --cpu)
                COLIMA_CPU="$2"
                shift 2
                ;;
            --memory)
                COLIMA_MEMORY="$2"
                shift 2
                ;;
            --disk)
                COLIMA_DISK="$2"
                shift 2
                ;;
            --profile)
                COLIMA_PROFILE="$2"
                shift 2
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}

# Function to check system requirements
check_requirements() {
    print_section "Checking System Requirements"
    
    # Check if running on macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is designed for macOS only"
        exit 1
    fi
    
    print_status "Running on macOS ✓"
    
    # Check if Homebrew is installed
    if ! command_exists brew; then
        print_error "Homebrew is required but not installed"
        print_status "Install Homebrew from: https://brew.sh"
        exit 1
    fi
    
    print_status "Homebrew is installed ✓"
    
    # Check available disk space (require at least 10GB free)
    available_space=$(df -h / | awk 'NR==2 {print $4}' | sed 's/G.*//')
    if [[ $available_space -lt 10 ]]; then
        print_warning "Low disk space detected (${available_space}GB free)"
        print_warning "Recommend at least 10GB free space for Colima"
    else
        print_status "Sufficient disk space available (${available_space}GB free) ✓"
    fi
}

# Function to install Homebrew packages
install_packages() {
    print_section "Installing Required Packages"
    
    local packages=("colima" "docker" "docker-compose")
    
    for package in "${packages[@]}"; do
        if brew list "$package" &>/dev/null; then
            print_status "$package is already installed ✓"
        else
            print_status "Installing $package..."
            if [[ "$VERBOSE" == "true" ]]; then
                brew install "$package"
            else
                brew install "$package" >/dev/null 2>&1
            fi
            print_status "$package installed successfully ✓"
        fi
    done
}

# Function to configure Colima
configure_colima() {
    print_section "Configuring Colima"
    
    # Stop Colima if it's running
    if colima status "$COLIMA_PROFILE" &>/dev/null; then
        print_status "Stopping existing Colima instance..."
        colima stop "$COLIMA_PROFILE" || true
    fi
    
    print_status "Colima configuration:"
    print_status "  Profile: $COLIMA_PROFILE"
    print_status "  CPU cores: $COLIMA_CPU"
    print_status "  Memory: ${COLIMA_MEMORY}GB"
    print_status "  Disk: ${COLIMA_DISK}GB"
}

# Function to start Colima
start_colima() {
    print_section "Starting Colima"
    
    print_status "Starting Colima with specified configuration..."
    
    if [[ "$VERBOSE" == "true" ]]; then
        colima start "$COLIMA_PROFILE" \
            --cpu "$COLIMA_CPU" \
            --memory "$COLIMA_MEMORY" \
            --disk "$COLIMA_DISK" \
            --vm-type=vz \
            --vz-rosetta
    else
        colima start "$COLIMA_PROFILE" \
            --cpu "$COLIMA_CPU" \
            --memory "$COLIMA_MEMORY" \
            --disk "$COLIMA_DISK" \
            --vm-type=vz \
            --vz-rosetta >/dev/null 2>&1
    fi
    
    print_status "Colima started successfully ✓"
}

# Function to verify installation
verify_installation() {
    print_section "Verifying Installation"
    
    # Check Colima status
    if colima status "$COLIMA_PROFILE" &>/dev/null; then
        print_status "Colima is running ✓"
    else
        print_warning "Colima is not running"
        return 1
    fi
    
    # Test Docker command
    if docker version &>/dev/null; then
        print_status "Docker CLI is working ✓"
    else
        print_error "Docker CLI is not working properly"
        return 1
    fi
    
    # Test with a simple container
    print_status "Testing with hello-world container..."
    if docker run --rm hello-world &>/dev/null; then
        print_status "Container execution test passed ✓"
    else
        print_error "Container execution test failed"
        return 1
    fi
    
    # Show Docker context
    docker_context=$(docker context show 2>/dev/null || echo "unknown")
    print_status "Current Docker context: $docker_context"
}

# Function to show post-installation info
show_post_install_info() {
    print_section "Installation Complete!"
    
    cat << EOF

${GREEN}Colima has been successfully installed and configured!${NC}

Quick start commands:
  colima start                    # Start Colima
  colima stop                     # Stop Colima
  colima status                   # Check Colima status
  colima list                     # List all profiles
  docker ps                       # List running containers
  docker images                   # List available images

Configuration used:
  Profile: $COLIMA_PROFILE
  CPU cores: $COLIMA_CPU
  Memory: ${COLIMA_MEMORY}GB
  Disk: ${COLIMA_DISK}GB

For more information:
  colima --help                   # Show Colima help
  docker --help                   # Show Docker help

${YELLOW}Note:${NC} Colima uses a lightweight VM to run containers. The VM will
automatically start/stop with colima commands and persist between reboots.

EOF
}

# Function to handle cleanup on error
cleanup_on_error() {
    print_error "Installation failed. Cleaning up..."
    
    # Stop Colima if it was started
    colima stop "$COLIMA_PROFILE" 2>/dev/null || true
    
    exit 1
}

# Main installation function
main() {
    trap cleanup_on_error ERR
    
    parse_args "$@"
    
    print_section "Colima Setup for macOS"
    print_status "This script will install and configure Colima (container runtime)"
    
    check_requirements
    install_packages
    configure_colima
    
    if [[ "$START_AFTER_INSTALL" == "true" ]]; then
        start_colima
        verify_installation
    else
        print_status "Skipping Colima startup (--no-start specified)"
        print_status "Run 'colima start $COLIMA_PROFILE' to start when ready"
    fi
    
    show_post_install_info
    
    print_status "Setup completed successfully! 🎉"
}

# Run main function with all arguments
main "$@"
