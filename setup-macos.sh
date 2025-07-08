#!/bin/bash

# Setup script for Eversense Companion on macOS
# This script installs all dependencies required to build and run the project

set -e

echo "====================================================="
echo "Eversense Companion - macOS Setup Script"
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

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is for macOS only. Use setup-linux.sh for Linux."
    exit 1
fi

# Check for Xcode Command Line Tools
echo "1. Checking Xcode Command Line Tools..."
if xcode-select -p >/dev/null 2>&1; then
    print_status "Xcode Command Line Tools are installed"
else
    print_info "Installing Xcode Command Line Tools..."
    xcode-select --install
    print_warning "Please complete the Xcode Command Line Tools installation and run this script again"
    exit 1
fi

# Install Homebrew if not present
echo ""
echo "2. Installing Homebrew (if needed)..."
if command_exists brew; then
    print_status "Homebrew is already installed"
    # Update Homebrew
    brew update
else
    print_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for current session
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        # Apple Silicon Mac
        eval "$(/opt/homebrew/bin/brew shellenv)"
        HOMEBREW_PREFIX="/opt/homebrew"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        # Intel Mac
        eval "$(/usr/local/bin/brew shellenv)"
        HOMEBREW_PREFIX="/usr/local"
    fi
    
    print_status "Homebrew installed successfully"
fi

# Install system dependencies
echo ""
echo "3. Installing system dependencies..."
print_info "Installing wget, curl, unzip..."
brew install wget curl unzip

# Install Java
echo ""
echo "4. Installing Java..."
if command_exists java; then
    JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f 2)
    print_status "Java is already installed: $JAVA_VERSION"
    
    # Find JAVA_HOME
    if [[ -z "$JAVA_HOME" ]]; then
        JAVA_HOME=$(/usr/libexec/java_home -v 11 2>/dev/null || /usr/libexec/java_home 2>/dev/null)
        export JAVA_HOME
    fi
else
    print_info "Installing OpenJDK 11..."
    brew install openjdk@11
    
    # Set up symlink for system Java wrappers
    sudo ln -sfn $(brew --prefix)/opt/openjdk@11/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-11.jdk
    
    JAVA_HOME=$(brew --prefix)/opt/openjdk@11
    export JAVA_HOME
    
    print_status "Java installed successfully"
fi

echo "JAVA_HOME: $JAVA_HOME"

# Install Node.js and npm
echo ""
echo "5. Installing Node.js and npm..."
if command_exists node && command_exists npm; then
    NODE_VERSION=$(node --version)
    NPM_VERSION=$(npm --version)
    print_status "Node.js is already installed: $NODE_VERSION"
    print_status "npm is already installed: $NPM_VERSION"
    
    # Check if version is sufficient (16+)
    NODE_MAJOR_VERSION=$(echo $NODE_VERSION | cut -d'.' -f1 | sed 's/v//')
    if [ "$NODE_MAJOR_VERSION" -lt 16 ]; then
        print_warning "Node.js version is below 16. Installing latest LTS..."
        brew install node
    fi
else
    print_info "Installing Node.js and npm..."
    brew install node
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

# Install Python and pip
echo ""
echo "6. Installing Python..."
if command_exists python3; then
    PYTHON_VERSION=$(python3 --version)
    print_status "Python is already installed: $PYTHON_VERSION"
else
    print_info "Installing Python..."
    brew install python
fi

# Verify Python installation
if command_exists python3; then
    PYTHON_VERSION=$(python3 --version)
    print_status "Python installed: $PYTHON_VERSION"
    
    # Install requests library for eversense_client.py
    pip3 install requests
    print_status "Python dependencies installed"
else
    print_error "Python installation failed"
    exit 1
fi

# Install browser dependencies
echo ""
echo "7. Installing browser application dependencies..."
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
echo "8. Setting up Garmin Connect IQ SDK..."
SDK_VERSION="4.2.4"
SDK_PATH="$HOME/.garmin-sdk"

if [ ! -d "$SDK_PATH" ]; then
    print_info "Downloading Connect IQ SDK v$SDK_VERSION..."
    mkdir -p "$SDK_PATH"
    
    # Download SDK for macOS
    wget -O /tmp/connectiq-sdk.dmg "https://developer.garmin.com/downloads/connect-iq/sdks/connectiq-sdk-mac-${SDK_VERSION}.dmg"
    
    # Mount the DMG
    print_info "Mounting SDK installer..."
    hdiutil mount /tmp/connectiq-sdk.dmg -quiet
    
    # Find the mounted volume
    MOUNT_POINT=$(hdiutil info | grep "connectiq-sdk" | awk '{print $1}' | head -1)
    VOLUME_PATH="/Volumes/connectiq-sdk-mac-${SDK_VERSION}"
    
    if [ -d "$VOLUME_PATH" ]; then
        # Copy SDK contents
        cp -R "$VOLUME_PATH"/* "$SDK_PATH/"
        print_status "Connect IQ SDK copied to $SDK_PATH"
        
        # Unmount the DMG
        hdiutil unmount "$VOLUME_PATH" -quiet
    else
        print_warning "DMG mount failed. Trying alternative download method..."
        # Fallback: try downloading the zip version (if available)
        wget -O /tmp/connectiq-sdk.zip "https://developer.garmin.com/downloads/connect-iq/sdks/connectiq-sdk-mac-${SDK_VERSION}.zip" || {
            print_error "Failed to download SDK. Please download manually from:"
            print_error "https://developer.garmin.com/connect-iq/sdk/"
            exit 1
        }
        unzip /tmp/connectiq-sdk.zip -d "$SDK_PATH"
        rm /tmp/connectiq-sdk.zip
    fi
    
    # Clean up
    rm -f /tmp/connectiq-sdk.dmg
    
    # Make binaries executable
    if [ -d "$SDK_PATH/bin" ]; then
        chmod +x "$SDK_PATH"/bin/*
    fi
    
    print_status "Connect IQ SDK installed to $SDK_PATH"
else
    print_status "Connect IQ SDK already exists at $SDK_PATH"
fi

# Configure environment
echo ""
echo "9. Configuring environment..."

# Create environment setup
ENV_SETUP="# Eversense Companion environment
export JAVA_HOME=$JAVA_HOME
export CIQ_SDK_PATH=$SDK_PATH
export PATH=\$PATH:\$CIQ_SDK_PATH/bin"

# Add to .zshrc (default shell on modern macOS)
if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "CIQ_SDK_PATH" "$HOME/.zshrc"; then
        echo "" >> "$HOME/.zshrc"
        echo "$ENV_SETUP" >> "$HOME/.zshrc"
        print_status "Environment variables added to ~/.zshrc"
    fi
fi

# Add to .bash_profile for bash users
if [ -f "$HOME/.bash_profile" ]; then
    if ! grep -q "CIQ_SDK_PATH" "$HOME/.bash_profile"; then
        echo "" >> "$HOME/.bash_profile"
        echo "$ENV_SETUP" >> "$HOME/.bash_profile"
        print_status "Environment variables added to ~/.bash_profile"
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
echo "  1. Restart your terminal or run: source ~/.zshrc (or ~/.bash_profile)"
echo "  2. Test the setup by running:"
echo "     cd browser && npm run dev    # Start browser app"
echo "     cd garmin && ./build.sh      # Build Garmin app"
echo "     python3 eversense_client.py --help  # Test Python client"
echo ""
echo "For more information, see:"
echo "  - Browser app: browser/README.md"
echo "  - Garmin app: garmin/DEVELOPMENT.md"
echo ""