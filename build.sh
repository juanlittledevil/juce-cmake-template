#!/bin/bash

# JUCE CMake Build Script

set -e  # Exit on error

echo "🎵 Building JUCE Template Project..."

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
echo "📦 Built artifacts:"
echo "   • Standalone App: ./build/src/JuceTemplate_artefacts/Release/Standalone/Juce Template.app"
echo "   • AU Plugin:      ./build/src/JuceTemplate_artefacts/Release/AU/Juce Template.component"
echo "   • VST3 Plugin:    ./build/src/JuceTemplate_artefacts/Release/VST3/Juce Template.vst3"
echo ""
echo "🚀 To run the standalone app:"
echo "   open \"./build/src/JuceTemplate_artefacts/Release/Standalone/Juce Template.app\""
echo ""
echo "💡 Plugins have been automatically installed to your system plugin folders!"