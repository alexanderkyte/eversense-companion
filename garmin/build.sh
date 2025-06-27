#!/bin/bash

# Build script for Eversense Companion Garmin Watchface
# This script helps build the watchface even without the full Connect IQ SDK

set -e

echo "Eversense Companion Garmin Watchface Build Script"
echo "================================================="

# Check if Connect IQ SDK is available
if command -v monkeyc >/dev/null 2>&1; then
    echo "✓ Connect IQ SDK found"
    
    # Default device
    DEVICE=${1:-vivoactive4}
    
    echo "Building for device: $DEVICE"
    
    # Build the watchface
    monkeyc \
        -m manifest.xml \
        -z resources/ \
        -o EversenseWatchface-$DEVICE.prg \
        -d $DEVICE \
        -w
    
    echo "✓ Build completed: EversenseWatchface-$DEVICE.prg"
    
else
    echo "⚠ Connect IQ SDK not found"
    echo ""
    echo "To build this watchface, you need the Garmin Connect IQ SDK:"
    echo "1. Download from: https://developer.garmin.com/connect-iq/sdk/"
    echo "2. Install and add 'bin' directory to your PATH"
    echo "3. Run this script again"
    echo ""
    echo "Alternatively, you can:"
    echo "- Import this project into Connect IQ IDE"
    echo "- Use Visual Studio Code with Connect IQ extension"
    echo ""
    echo "Project structure verification:"
    echo "✓ Manifest file: $(test -f manifest.xml && echo "Present" || echo "Missing")"
    echo "✓ Source files: $(find source -name "*.mc" | wc -l) files"
    echo "✓ Resource files: $(find resources -name "*.xml" | wc -l) files"
    echo "✓ README documentation: $(test -f README.md && echo "Present" || echo "Missing")"
    
    exit 1
fi