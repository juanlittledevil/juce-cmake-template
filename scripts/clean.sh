#!/bin/bash

# Clean build script - removes all build artifacts

echo "🧹 Cleaning JUCE Template Project..."
PWD=$(pwd)
cd ${PROJECT_HOME}

# Remove build directory
if [ -d "build" ]; then
    rm -rf build
    echo "   • Removed build directory"
fi

# Remove build-perf directory
if [ -d "build-perf" ]; then
    rm -rf build-perf
    echo "   • Removed build-perf directory"
fi

# Remove build-stress directory
if [ -d "build-stress" ]; then
    rm -rf build-stress
    echo "   • Removed build-stress directory"
fi

# Remove JUCE directory (will be re-downloaded on next build)
if [ -d "JUCE" ]; then
    rm -rf JUCE
    echo "   • Removed JUCE source directory"
fi

# Remove any .DS_Store files
find . -name ".DS_Store" -delete 2>/dev/null || true

cd $PWD

echo "✅ Clean completed!"
echo "💡 Run ./build.sh to rebuild the project"