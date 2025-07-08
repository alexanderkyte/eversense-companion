#!/bin/bash

# Setup script for Eversense Companion on Linux
# This script installs all dependencies required to build and run the project

set -e

echo "====================================================="
echo "Eversense Companion - Linux Setup Script"
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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check package manager
detect_package_manager() {
    if command_exists apt-get; then
        echo "apt"
    elif command_exists yum; then
        echo "yum"
    elif command_exists dnf; then
        echo "dnf"
    elif command_exists pacman; then
        echo "pacman"
    elif command_exists zypper; then
        echo "zypper"
    else
        echo "unknown"
    fi
}

# Function to install packages based on package manager
install_packages() {
    local pkg_manager=$(detect_package_manager)
    
    case $pkg_manager in
        "apt")
            print_info "Using apt package manager (Debian/Ubuntu)"
            sudo apt-get update
            sudo apt-get install -y curl wget unzip make openjdk-11-jdk python3 python3-pip
            ;;
        "yum")
            print_info "Using yum package manager (RHEL/CentOS)"
            sudo yum update -y
            sudo yum install -y curl wget unzip make java-11-openjdk-devel python3 python3-pip
            ;;
        "dnf")
            print_info "Using dnf package manager (Fedora)"
            sudo dnf update -y
            sudo dnf install -y curl wget unzip make java-11-openjdk-devel python3 python3-pip
            ;;
        "pacman")
            print_info "Using pacman package manager (Arch Linux)"
            sudo pacman -Syu --noconfirm
            sudo pacman -S --noconfirm curl wget unzip make jdk11-openjdk python python-pip
            ;;
        "zypper")
            print_info "Using zypper package manager (openSUSE)"
            sudo zypper refresh
            sudo zypper install -y curl wget unzip make java-11-openjdk-devel python3 python3-pip
            ;;
        *)
            print_error "Unknown package manager. Please install the following packages manually:"
            echo "  - curl, wget, unzip, make"
            echo "  - Java 11+ (OpenJDK recommended)"
            echo "  - Python 3 and pip"
            echo "  - Node.js 16+ and npm"
            exit 1
            ;;
    esac
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_warning "This script should not be run as root (except for package installation steps)"
fi

# System packages
echo "1. Installing system packages..."
install_packages
print_status "System packages installed"

# Check Java installation
echo ""
echo "2. Verifying Java installation..."
if command_exists java; then
    JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f 2)
    print_status "Java is installed: $JAVA_VERSION"
    export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
    echo "JAVA_HOME set to: $JAVA_HOME"
else
    print_error "Java installation failed"
    exit 1
fi

# Install Node.js and npm
echo ""
echo "3. Installing Node.js and npm..."
if command_exists node && command_exists npm; then
    NODE_VERSION=$(node --version)
    NPM_VERSION=$(npm --version)
    print_status "Node.js is already installed: $NODE_VERSION"
    print_status "npm is already installed: $NPM_VERSION"
    
    # Check if version is sufficient (16+)
    NODE_MAJOR_VERSION=$(echo $NODE_VERSION | cut -d'.' -f1 | sed 's/v//')
    if [ "$NODE_MAJOR_VERSION" -lt 16 ]; then
        print_warning "Node.js version is below 16. Installing latest LTS..."
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi
else
    print_info "Installing Node.js and npm..."
    # Install Node.js using NodeSource repository (works on most Linux distros)
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    if [ "$(detect_package_manager)" = "apt" ]; then
        sudo apt-get install -y nodejs
    else
        print_warning "Please install Node.js 16+ manually from https://nodejs.org/"
    fi
fi

# Verify Node.js installation
if command_exists node && command_exists npm; then
    NODE_VERSION=$(node --version)
    NPM_VERSION=$(npm --version)
    print_status "Node.js installed: $NODE_VERSION"
    print_status "npm installed: $NPM_VERSION"
else
    print_error "Node.js installation failed"
    exit 1
fi

# Install Python dependencies
echo ""
echo "4. Installing Python dependencies..."
if command_exists python3; then
    PYTHON_VERSION=$(python3 --version)
    print_status "Python is installed: $PYTHON_VERSION"
    
    # Install requests library for eversense_client.py
    pip3 install requests
    print_status "Python dependencies installed"
else
    print_error "Python installation failed"
    exit 1
fi

# Install browser dependencies
echo ""
echo "5. Installing browser application dependencies..."
if [ -d "browser" ]; then
    cd browser
    npm install
    print_status "Browser dependencies installed"
    cd ..
else
    print_warning "Browser directory not found. Skipping browser dependencies."
fi

# Download and setup Garmin Connect IQ SDK
echo ""
echo "6. Setting up Garmin Connect IQ SDK..."
SDK_VERSION="4.2.4"
SDK_PATH="$HOME/.garmin-sdk"

if [ ! -d "$SDK_PATH" ]; then
    print_info "Downloading Connect IQ SDK v$SDK_VERSION..."
    mkdir -p "$SDK_PATH"
    
    # Download SDK
    wget -O /tmp/connectiq-sdk.zip "https://developer.garmin.com/downloads/connect-iq/sdks/connectiq-sdk-lin-${SDK_VERSION}.zip"
    
    # Extract SDK
    unzip /tmp/connectiq-sdk.zip -d "$SDK_PATH"
    rm /tmp/connectiq-sdk.zip
    
    # Make binaries executable
    chmod +x "$SDK_PATH"/bin/*
    
    print_status "Connect IQ SDK installed to $SDK_PATH"
else
    print_status "Connect IQ SDK already exists at $SDK_PATH"
fi

# Add SDK to PATH in shell profiles
echo ""
echo "7. Configuring environment..."

# Create environment setup
ENV_SETUP="# Eversense Companion environment
export JAVA_HOME=$JAVA_HOME
export CIQ_SDK_PATH=$SDK_PATH
export PATH=\$PATH:\$CIQ_SDK_PATH/bin"

# Add to .bashrc if it exists
if [ -f "$HOME/.bashrc" ]; then
    if ! grep -q "CIQ_SDK_PATH" "$HOME/.bashrc"; then
        echo "" >> "$HOME/.bashrc"
        echo "$ENV_SETUP" >> "$HOME/.bashrc"
        print_status "Environment variables added to ~/.bashrc"
    fi
fi

# Add to .profile as fallback
if [ -f "$HOME/.profile" ]; then
    if ! grep -q "CIQ_SDK_PATH" "$HOME/.profile"; then
        echo "" >> "$HOME/.profile"
        echo "$ENV_SETUP" >> "$HOME/.profile"
        print_status "Environment variables added to ~/.profile"
    fi
fi

# Export for current session
export CIQ_SDK_PATH="$SDK_PATH"
export PATH="$PATH:$CIQ_SDK_PATH/bin"

echo ""
echo "====================================================="
echo "Setup Complete!"
echo "====================================================="
echo ""
print_status "All dependencies have been installed successfully!"
echo ""
echo "Environment setup:"
echo "  JAVA_HOME: $JAVA_HOME"
echo "  CIQ_SDK_PATH: $SDK_PATH"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal or run: source ~/.bashrc"
echo "  2. Test the setup by running:"
echo "     cd browser && npm run dev    # Start browser app"
echo "     cd garmin && ./build.sh      # Build Garmin app"
echo "     python3 eversense_client.py --help  # Test Python client"
echo ""
echo "For more information, see:"
echo "  - Browser app: browser/README.md"
echo "  - Garmin app: garmin/DEVELOPMENT.md"
echo ""