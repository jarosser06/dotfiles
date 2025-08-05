#!/bin/bash

# Simple Colima Setup Script
# Just starts Colima with sensible defaults, no arguments needed

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Simple logging
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

main() {
    log_info "Simple Colima Setup"
    
    # Check if colima is installed
    if ! command_exists colima; then
        log_error "Colima is not installed. Please install it with: brew install colima"
        exit 1
    fi
    
    # Check if colima is already running
    if colima status default >/dev/null 2>&1; then
        log_info "Colima is already running"
        exit 0
    fi
    
    # Start colima with simple defaults
    log_info "Starting Colima with default settings..."
    if colima start; then
        log_info "✅ Colima started successfully"
    else
        log_warning "Colima start failed, but continuing..."
        exit 1
    fi
    
    # Verify it's working
    if colima status default >/dev/null 2>&1; then
        log_info "✅ Colima is running and ready"
    else
        log_error "❌ Colima failed to start properly"
        exit 1
    fi
}

main "$@"