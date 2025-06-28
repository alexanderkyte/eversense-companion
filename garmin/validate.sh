#!/bin/bash

# Simple validation script for the Garmin watchface
# Checks file structure and basic syntax

echo "Eversense Companion Garmin Watchface Validation"
echo "=============================================="

PROJECT_ROOT="/home/runner/work/eversense-companion/eversense-companion/garmin"
cd "$PROJECT_ROOT"

errors=0

# Check required files exist
echo "Checking required files..."
required_files=(
    "manifest.xml"
    "source/EversenseApp.mc"
    "source/EversenseWatchFaceView.mc"
    "source/EversenseWatchFaceDelegate.mc"
    "source/EversenseAPIClient.mc"
    "source/EversenseBaseView.mc"
    "source/EversenseDataFieldView.mc"
    "source/EversenseTestUtils.mc"
    "resources/strings/strings.xml"
    "resources/drawables/drawables.xml"
    "settings.json"
    "README.md"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ $file"
    else
        echo "✗ $file (missing)"
        ((errors++))
    fi
done

# Check manifest.xml structure
echo ""
echo "Checking manifest.xml..."
if grep -q "EversenseWatchFaceApp" manifest.xml; then
    echo "✓ Entry point defined"
else
    echo "✗ Entry point missing"
    ((errors++))
fi

if grep -q "Communications" manifest.xml; then
    echo "✓ Communications permission"
else
    echo "✗ Communications permission missing"
    ((errors++))
fi

if grep -q "settings.json" manifest.xml; then
    echo "✓ Settings file referenced"
else
    echo "✗ Settings file not referenced"
    ((errors++))
fi

# Check source files for basic structure
echo ""
echo "Checking source files..."

# Check for key classes
if grep -q "class EversenseWatchFaceApp\|class EversenseDataFieldApp" source/EversenseApp.mc; then
    echo "✓ Main app class defined"
else
    echo "✗ Main app class missing"
    ((errors++))
fi

if grep -q "class EversenseWatchFaceView" source/EversenseWatchFaceView.mc; then
    echo "✓ View class defined"
else
    echo "✗ View class missing"
    ((errors++))
fi

if grep -q "class EversenseAPIClient" source/EversenseAPIClient.mc; then
    echo "✓ API client class defined"
else
    echo "✗ API client class missing"
    ((errors++))
fi

# Check for essential functionality
if grep -q "fetchLatestGlucose" source/EversenseAPIClient.mc; then
    echo "✓ Glucose fetching function"
else
    echo "✗ Glucose fetching function missing"
    ((errors++))
fi

if grep -q "drawGlucose" source/EversenseWatchFaceView.mc; then
    echo "✓ Glucose display function"
else
    echo "✗ Glucose display function missing"
    ((errors++))
fi

if grep -q "Timer" source/EversenseWatchFaceView.mc; then
    echo "✓ Timer functionality for updates"
else
    echo "✗ Timer functionality missing"
    ((errors++))
fi

# Check settings.json structure
echo ""
echo "Checking settings.json..."
if grep -q "username" settings.json; then
    echo "✓ Username setting"
else
    echo "✗ Username setting missing"
    ((errors++))
fi

if grep -q "updateInterval" settings.json; then
    echo "✓ Update interval setting"
else
    echo "✗ Update interval setting missing"
    ((errors++))
fi

# Summary
echo ""
echo "=============================================="
if [ $errors -eq 0 ]; then
    echo "✅ All validation checks passed!"
    echo "The Garmin watchface appears to be properly structured."
    echo ""
    echo "Next steps:"
    echo "1. Install Garmin Connect IQ SDK"
    echo "2. Configure credentials in settings"
    echo "3. Build and test on device/simulator"
    exit 0
else
    echo "❌ Found $errors issue(s)"
    echo "Please review and fix the issues above."
    exit 1
fi