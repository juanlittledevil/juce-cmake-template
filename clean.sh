#!/bin/bash

# Clean build script - removes all build artifacts

echo "🧹 Cleaning JUCE Template Project..."

# Remove build directory
if [ -d "build" ]; then
    rm -rf build
    echo "   • Removed build directory"
fi

# Remove JUCE directory (will be re-downloaded on next build)
if [ -d "JUCE" ]; then
    rm -rf JUCE
    echo "   • Removed JUCE source directory"
fi

# Remove any .DS_Store files
find . -name ".DS_Store" -delete 2>/dev/null || true

echo "✅ Clean completed!"
echo "💡 Run ./build.sh to rebuild the project"