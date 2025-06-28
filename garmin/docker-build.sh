#!/bin/bash
set -e

echo "Building Eversense Garmin Apps..."

# Supported devices
DEVICES=(
    "vivoactive4"
    "vivoactive4s" 
    "venu"
    "venu2"
    "venu2s"
    "fenix6"
    "fenix6s"
    "fenix6x"
    "forerunner245"
)

# Create output directory
mkdir -p /workspace/dist

# Build for each device
for device in "${DEVICES[@]}"; do
    echo "Building for $device..."
    
    # Build watchface
    monkeyc \
        -m manifest.xml \
        -z resources/ \
        -o "dist/EversenseWatchface-${device}.prg" \
        -d "$device" \
        -w \
        --package-app eversense-watchface
    
    # Build datafield
    monkeyc \
        -m manifest.xml \
        -z resources/ \
        -o "dist/EversenseDataField-${device}.prg" \
        -d "$device" \
        -w \
        --package-app eversense-datafield
done

# Copy documentation
cp README.md dist/
cp DEVELOPMENT.md dist/

# Create package
cd dist && tar -czf eversense-garmin-apps.tar.gz *.prg *.md

echo "Build complete! Artifacts in /workspace/dist/"
ls -la /workspace/dist/