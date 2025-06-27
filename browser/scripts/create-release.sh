#!/bin/bash

# Build and package the Eversense Companion static site
# This script creates the same archives that GitHub Actions produces

set -e

echo "🩸 Building Eversense Companion Release..."

# Clean previous build
echo "🧹 Cleaning previous build..."
rm -rf dist/
rm -f eversense-companion-static-site.zip
rm -f eversense-companion-static-site.tar.gz

# Build the static site
echo "🔨 Building static site..."
npm run build

# Verify build output
if [ ! -d "dist" ]; then
    echo "❌ Build failed - dist directory not found"
    exit 1
fi

echo "✅ Build completed successfully"

# Create archives
echo "📦 Creating release archives..."
cd dist

# Create ZIP archive
zip -r ../eversense-companion-static-site.zip . -x "*.DS_Store" "*Thumbs.db"
echo "✅ Created eversense-companion-static-site.zip"

# Create TAR.GZ archive
tar --exclude="*.DS_Store" --exclude="*Thumbs.db" -czf ../eversense-companion-static-site.tar.gz .
echo "✅ Created eversense-companion-static-site.tar.gz"

cd ..

# Show file sizes
echo ""
echo "📊 Release archives created:"
ls -lh eversense-companion-static-site.*

echo ""
echo "🎉 Release package created successfully!"
echo ""
echo "📁 Contents included:"
echo "   - index.html (Complete HTML application)"
echo "   - api.js (Eversense API integration)"
echo "   - app.js (Main application logic)"
echo "   - chart.js (D3.js chart component)"
echo ""
echo "🚀 To deploy:"
echo "   1. Extract either archive to your web server"
echo "   2. Serve the files from any static hosting service"
echo "   3. Access index.html in a web browser"
echo "   4. Enter Eversense credentials to view glucose data"