#!/bin/bash

# Main setup script for Eversense Companion
# Automatically detects the platform and runs the appropriate setup script

set -e

echo "====================================================="
echo "Eversense Companion - Automatic Setup"
echo "====================================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Detect operating system
detect_os() {
    case "$OSTYPE" in
        linux*)
            echo "linux"
            ;;
        darwin*)
            echo "macos"
            ;;
        cygwin|msys|win32)
            echo "windows"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect OS
OS=$(detect_os)
print_info "Detected operating system: $OS"

echo ""
echo "This script will install all dependencies required to build and run:"
echo "  • Browser application (Node.js + npm)"
echo "  • Garmin watchface/datafield (Java + Connect IQ SDK)"
echo "  • Python client (Python + requests)"
echo ""

# Check if running on Windows (in Git Bash or WSL)
if [[ "$OS" == "windows" ]]; then
    print_warning "Windows detected. For best results, use one of these options:"
    echo ""
    echo "Option 1 (Recommended): PowerShell"
    echo "  • Open PowerShell as Administrator"
    echo "  • Run: ./setup-windows.ps1"
    echo ""
    echo "Option 2: Command Prompt"
    echo "  • Open Command Prompt as Administrator"
    echo "  • Run: setup-windows.bat"
    echo ""
    echo "Option 3: Continue with Git Bash (current)"
    echo "  • Some features may not work as expected"
    echo ""
    read -p "Continue with Git Bash setup? (y/N): " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Please use one of the recommended Windows setup methods."
        exit 1
    fi
    
    # Try to run Linux setup as fallback (for WSL-like environments)
    OS="linux"
fi

case $OS in
    "linux")
        print_info "Running Linux setup script..."
        if [[ -f "$SCRIPT_DIR/setup-linux.sh" ]]; then
            bash "$SCRIPT_DIR/setup-linux.sh"
        else
            print_error "Linux setup script not found at $SCRIPT_DIR/setup-linux.sh"
            exit 1
        fi
        ;;
    "macos")
        print_info "Running macOS setup script..."
        if [[ -f "$SCRIPT_DIR/setup-macos.sh" ]]; then
            bash "$SCRIPT_DIR/setup-macos.sh"
        else
            print_error "macOS setup script not found at $SCRIPT_DIR/setup-macos.sh"
            exit 1
        fi
        ;;
    *)
        print_error "Unsupported operating system: $OS"
        echo ""
        echo "Please use the platform-specific setup scripts:"
        echo "  • Linux: ./setup-linux.sh"
        echo "  • macOS: ./setup-macos.sh" 
        echo "  • Windows: setup-windows.bat or setup-windows.ps1"
        exit 1
        ;;
esac

echo ""
print_status "Platform-specific setup completed!"
echo ""
echo "Universal next steps:"
echo "  1. Restart your terminal to ensure all environment variables are loaded"
echo "  2. Test the browser app: cd browser && npm run dev"
echo "  3. Test the Garmin build: cd garmin && ./build.sh"
echo "  4. Test the Python client: python3 eversense_client.py --help"
echo ""