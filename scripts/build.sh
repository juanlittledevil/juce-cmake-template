#!/bin/bash

# JUCE CMake Build Script

set -e  # Exit on error
PWD=$(pwd)

# Get the directory where this script is located (project root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

# Extract project name from CMakeLists.txt
PROJECT_NAME=$(grep "^project(" CMakeLists.txt | sed 's/project(\([^ ]*\).*/\1/' | head -1)

if [ -z "$PROJECT_NAME" ]; then
    # Fallback to directory name if project name not found
    PROJECT_NAME=$(basename "$PWD")
fi

BUILD_TYPE="Release"
BUILD_DIR="build"
USE_ASAN="OFF"
ENABLE_UI_DEBUG="OFF"
ENABLE_PROCESSBLOCK_DEBUG="OFF"
ENABLE_DEBUG_VISUALIZATIONS="OFF"
ENABLE_PERFORMANCE_BENCHMARKING="OFF"
ENABLE_THREAD_SAFETY_STRESS_TESTS="OFF"
ENABLE_EXTENDED_EDGE_CASE_TESTS="OFF"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --asan|-a)
            USE_ASAN="ON"
            BUILD_TYPE="Debug"
            BUILD_DIR="build-asan"
            ;;
        --build-type|-t)
            shift
            if [[ -n "$1" ]]; then
                BUILD_TYPE="$1"
            else
                echo "⚠️  Missing value for --build-type"
                exit 1
            fi
            ;;
        --debug|-g)
            # DO NOT shift here; --debug is a flag without a following value.
            # The final 'shift' at the end of the while loop advances to the
            # next argument. An extra shift here would consume the next flag
            # or value erroneously.
            BUILD_TYPE="Debug"
            ;;
        --build-dir|-d)
            shift
            if [[ -n "$1" ]]; then
                BUILD_DIR="$1"
            else
                echo "⚠️  Missing value for --build-dir"
                exit 1
            fi
            ;;
        --help|-h)
            cat <<EOF
Usage: ./scripts/build.sh [options]

Options:
    --asan, -a        Configure a debug build with AddressSanitizer enabled (uses build-asan dir).
    --build-type, -t TYPE Override CMAKE_BUILD_TYPE (defaults to Release).
    --build-dir, -d DIR   Override build directory (defaults to build or build-asan when --asan used).
    --debug, -g       Shortcut to set build type to Debug.
    --ui-debug        Compile-time flag to enable UI debug helpers (sets -DENABLE_UI_DEBUG=ON).
    --enable-ui-debug Alias for --ui-debug.
    --processblock-debug Enable verbose processBlock logging helpers.
    --debug-visualizations Turn on gap/discontinuity overlays and related UI aids.
    --perf-benchmarks Enable performance benchmarking utilities.
    --thread-stress-tests Enable thread-safety stress test instrumentation.
    --edge-tests      Enable extended edge case validation harnesses.
    --help            Show this message and exit.
EOF
            exit 0
            ;;
        --ui-debug|--enable-ui-debug)
            ENABLE_UI_DEBUG="ON"
            ;;
        --processblock-debug)
            ENABLE_PROCESSBLOCK_DEBUG="ON"
            ;;
        --debug-visualizations)
            ENABLE_DEBUG_VISUALIZATIONS="ON"
            ;;
        --perf-benchmarks|--enable-perf-benchmarks)
            ENABLE_PERFORMANCE_BENCHMARKING="ON"
            ;;
        --thread-stress-tests|--enable-thread-stress)
            ENABLE_THREAD_SAFETY_STRESS_TESTS="ON"
            ;;
        --edge-tests|--enable-edge-tests)
            ENABLE_EXTENDED_EDGE_CASE_TESTS="ON"
            ;;
        *)
            echo "⚠️  Unknown option: $1"
            exit 1
            ;;
    esac
    shift
done

echo "🎵 Building $PROJECT_NAME Project ($BUILD_TYPE) ..."
if [[ "$USE_ASAN" == "ON" ]]; then
    echo "🧪 AddressSanitizer enabled"
fi

# Create build directory if it doesn't exist
if [ ! -d "$BUILD_DIR" ]; then
    mkdir -p "$BUILD_DIR"
fi

cd "$BUILD_DIR"

# Configure the project
echo "📋 Configuring project..."
cmake .. -DCMAKE_BUILD_TYPE="$BUILD_TYPE" -Wno-dev \
    -DUSE_ASAN="$USE_ASAN" \
    -DENABLE_UI_DEBUG="$ENABLE_UI_DEBUG" \
    -DENABLE_PROCESSBLOCK_DEBUG="$ENABLE_PROCESSBLOCK_DEBUG" \
    -DENABLE_DEBUG_VISUALIZATIONS="$ENABLE_DEBUG_VISUALIZATIONS" \
    -DENABLE_PERFORMANCE_BENCHMARKING="$ENABLE_PERFORMANCE_BENCHMARKING" \
    -DENABLE_THREAD_SAFETY_STRESS_TESTS="$ENABLE_THREAD_SAFETY_STRESS_TESTS" \
    -DENABLE_EXTENDED_EDGE_CASE_TESTS="$ENABLE_EXTENDED_EDGE_CASE_TESTS" \
    # Note: removed project-specific PRECALC and buffer-instruction flags to keep template generic

# Build the project
echo "🔨 Building project..."
cmake --build . --config "$BUILD_TYPE" --parallel $(sysctl -n hw.logicalcpu)

echo ""
echo "✅ Build completed successfully!"
echo ""

# Find actual artifact names (they may have spaces or different naming)
ARTIFACT_ROOT="./src/${PROJECT_NAME}_artefacts/${BUILD_TYPE}"
STANDALONE_APP=$(find "${ARTIFACT_ROOT}/Standalone" -name "*.app" 2>/dev/null | head -1)
AU_PLUGIN=$(find "${ARTIFACT_ROOT}/AU" -name "*.component" 2>/dev/null | head -1)
VST3_PLUGIN=$(find "${ARTIFACT_ROOT}/VST3" -name "*.vst3" 2>/dev/null | head -1)

echo "📦 Built artifacts:"
if [ -n "$STANDALONE_APP" ]; then
    echo "   • Standalone App: ./${BUILD_DIR}/${STANDALONE_APP#./}"
fi
if [ -n "$AU_PLUGIN" ]; then
    echo "   • AU Plugin:      ./${BUILD_DIR}/${AU_PLUGIN#./}"
fi
if [ -n "$VST3_PLUGIN" ]; then
    echo "   • VST3 Plugin:    ./${BUILD_DIR}/${VST3_PLUGIN#./}"
fi

echo ""
if [ -n "$STANDALONE_APP" ]; then
    echo "🚀 To run the standalone app:"
    echo "   open \"./${BUILD_DIR}/${STANDALONE_APP#./}\""
    echo ""
fi

cd "$PWD"

echo "💡 Plugins have been automatically installed to your system plugin folders!"