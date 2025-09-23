#!/bin/bash

# JUCE CMake Build Script

set -e  # Exit on error

# Extract project name from CMakeLists.txt
PROJECT_NAME=$(grep "^project(" CMakeLists.txt | sed 's/project(\([^ ]*\).*/\1/' | head -1)

if [ -z "$PROJECT_NAME" ]; then
    # Fallback to directory name if project name not found
    PROJECT_NAME=$(basename "$PWD")
fi

echo "🎵 Building $PROJECT_NAME Project..."

# Create build directory if it doesn't exist
if [ ! -d "build" ]; then
    mkdir build
fi

cd build

# Configure the project
echo "📋 Configuring project..."
cmake .. -DCMAKE_BUILD_TYPE=Release -Wno-dev

# Build the project
echo "🔨 Building project..."
cmake --build . --config Release --parallel $(sysctl -n hw.logicalcpu)

echo ""
echo "✅ Build completed successfully!"
echo ""

# Find actual artifact names (they may have spaces or different naming)
STANDALONE_APP=$(find "./src/${PROJECT_NAME}_artefacts/Release/Standalone" -name "*.app" 2>/dev/null | head -1)
AU_PLUGIN=$(find "./src/${PROJECT_NAME}_artefacts/Release/AU" -name "*.component" 2>/dev/null | head -1)
VST3_PLUGIN=$(find "./src/${PROJECT_NAME}_artefacts/Release/VST3" -name "*.vst3" 2>/dev/null | head -1)

echo "📦 Built artifacts:"
if [ -n "$STANDALONE_APP" ]; then
    echo "   • Standalone App: ./build/$STANDALONE_APP"
fi
if [ -n "$AU_PLUGIN" ]; then
    echo "   • AU Plugin:      ./build/$AU_PLUGIN"
fi
if [ -n "$VST3_PLUGIN" ]; then
    echo "   • VST3 Plugin:    ./build/$VST3_PLUGIN"
fi

echo ""
if [ -n "$STANDALONE_APP" ]; then
    echo "🚀 To run the standalone app:"
    echo "   open \"./build/$STANDALONE_APP\""
    echo ""
fi
echo "💡 Plugins have been automatically installed to your system plugin folders!"