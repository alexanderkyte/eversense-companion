#!/bin/bash

# Test script to validate the setup was successful
# This script checks that all dependencies are properly installed

set -e

echo "====================================================="
echo "Eversense Companion - Setup Validation"
echo "====================================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_pass() {
    echo -e "${GREEN}✓ PASS${NC} $1"
}

print_fail() {
    echo -e "${RED}❌ FAIL${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ INFO${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

FAILED_TESTS=0

echo "Testing core system dependencies..."
echo ""

# Test Node.js
if command_exists node; then
    NODE_VERSION=$(node --version)
    print_pass "Node.js is installed: $NODE_VERSION"
    
    # Check version
    NODE_MAJOR_VERSION=$(echo $NODE_VERSION | cut -d'.' -f1 | sed 's/v//')
    if [ "$NODE_MAJOR_VERSION" -ge 16 ]; then
        print_pass "Node.js version is 16 or higher"
    else
        print_fail "Node.js version is below 16 (current: $NODE_VERSION)"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
else
    print_fail "Node.js not found"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test npm
if command_exists npm; then
    NPM_VERSION=$(npm --version)
    print_pass "npm is installed: $NPM_VERSION"
else
    print_fail "npm not found"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test Python
if command_exists python3; then
    PYTHON_VERSION=$(python3 --version)
    print_pass "Python is installed: $PYTHON_VERSION"
    
    # Test requests module
    if python3 -c "import requests" 2>/dev/null; then
        print_pass "Python requests module is available"
    else
        print_fail "Python requests module not found"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
else
    print_fail "Python not found"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test Java
if command_exists java; then
    JAVA_VERSION=$(java -version 2>&1 | head -n 1)
    print_pass "Java is installed: $JAVA_VERSION"
else
    print_fail "Java not found"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

echo ""
echo "Testing project-specific dependencies..."
echo ""

# Test browser dependencies
if [ -d "browser" ]; then
    cd browser
    if [ -f "package.json" ]; then
        if npm list --depth=0 >/dev/null 2>&1; then
            print_pass "Browser dependencies are installed"
        else
            print_fail "Browser dependencies are missing or broken"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    else
        print_fail "Browser package.json not found"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    cd ..
else
    print_fail "Browser directory not found"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test Python client
if python3 eversense_client.py --help >/dev/null 2>&1; then
    print_pass "Python client can run"
else
    print_fail "Python client cannot run"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test Garmin SDK (if installed)
if [[ -n "$CIQ_SDK_PATH" ]] && [[ -d "$CIQ_SDK_PATH" ]]; then
    print_pass "Garmin SDK path is set: $CIQ_SDK_PATH"
    
    if command_exists monkeyc; then
        print_pass "Garmin monkeyc compiler is available"
    elif [[ -f "$CIQ_SDK_PATH/bin/monkeyc" ]]; then
        print_pass "Garmin monkeyc compiler found in SDK"
    else
        print_fail "Garmin monkeyc compiler not found"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
else
    print_info "Garmin SDK not installed or path not set"
    print_info "This is optional - run setup script to install"
fi

echo ""
echo "Testing project functionality..."
echo ""

# Test browser build
if [ -d "browser" ]; then
    cd browser
    if npm run build >/dev/null 2>&1; then
        print_pass "Browser application can build"
        
        # Check if dist directory was created
        if [ -d "dist" ]; then
            print_pass "Browser build output directory created"
        else
            print_fail "Browser build did not create output directory"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    else
        print_fail "Browser application build failed"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    cd ..
fi

# Test Garmin build (if possible)
if [ -d "garmin" ] && command_exists bash; then
    cd garmin
    # Test if build script exists and can provide information
    if [[ -f "build.sh" ]] && bash build.sh >/dev/null 2>&1; then
        print_pass "Garmin build script can run"
    elif [[ -f "build.sh" ]]; then
        print_info "Garmin build script exists but requires SDK setup"
    else
        print_fail "Garmin build script not found"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    cd ..
fi

echo ""
echo "====================================================="
if [ $FAILED_TESTS -eq 0 ]; then
    print_pass "All tests passed! Setup is complete and functional."
    echo ""
    echo "You can now:"
    echo "  • Start the browser app: cd browser && npm run dev"
    echo "  • Build Garmin apps: cd garmin && ./build.sh"
    echo "  • Use Python client: python3 eversense_client.py --help"
else
    print_fail "$FAILED_TESTS tests failed. Some dependencies may need manual installation."
    echo ""
    echo "Try running the setup script again:"
    echo "  • Linux/macOS: ./setup.sh"
    echo "  • Windows: setup-windows.bat or setup-windows.ps1"
fi
echo "====================================================="
echo ""

exit $FAILED_TESTS