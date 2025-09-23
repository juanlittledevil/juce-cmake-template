#!/bin/bash

# JUCE CMake Test Build Script

set -e  # Exit on error

echo "🧪 Building and Running Unit Tests..."

# Create build directory if it doesn't exist
if [ ! -d "build" ]; then
    mkdir build
fi

cd build

# Configure the project with tests enabled
echo "📋 Configuring project with tests..."
cmake .. -DCMAKE_BUILD_TYPE=Debug -DBUILD_TESTING=ON -Wno-dev

# Build the tests
echo "🔨 Building unit tests..."
cmake --build . --target UnitTests --config Debug --parallel $(sysctl -n hw.logicalcpu)

echo ""
echo "✅ Test build completed successfully!"

# Check if test executable exists
if [ -f "./tests/UnitTests" ]; then
    echo ""
    echo "🚀 Running tests..."
    echo "=================="
    ./tests/UnitTests
else
    echo "❌ Test executable not found!"
    exit 1
fi