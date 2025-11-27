#!/bin/bash

# TurnTabby Comprehensive Test Runner
# Builds once and runs multiple test types from the same build

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Default options
BUILD_TYPE="Release"
ENABLE_STRESS=1
ENABLE_PERF=1
RUN_UNIT=1
RUN_STRESS=1
RUN_BENCH=1
PERF_THRESHOLD_MS=50
RUN_LONG_STRESS=0
FAIL_ON_BENCH_EXCEED=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

usage() {
    cat << EOF
Usage: $0 [options]

Builds TurnTabby once with testing features and runs multiple test types.

Options:
  --build-type TYPE       Build type (Release, Debug) [default: Release]
  --enable-stress BOOL    Enable thread safety stress testing (0/1) [default: 1]
  --enable-perf BOOL      Enable performance benchmarking (0/1) [default: 1]
  --run-unit BOOL         Run unit tests (0/1) [default: 1]
  --run-stress BOOL       Run stress tests (0/1) [default: 1]
  --run-bench BOOL        Run benchmarks (0/1) [default: 1]
  --perf-threshold MS     Performance threshold for unit tests [default: 50]
  --run-long-stress BOOL  Run long stress tests (0/1) [default: 0]
  --fail-on-bench-exceed  Fail if benchmarks exceed thresholds (0/1) [default: 0]
  -h, --help              Show this help

Examples:
  $0  # Run all tests with defaults
  $0 --run-stress 0 --run-bench 0  # Only unit tests
  $0 --fail-on-bench-exceed  # CI mode with benchmark failure
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --build-type) BUILD_TYPE="$2"; shift 2 ;;
        --enable-stress) ENABLE_STRESS="$2"; shift 2 ;;
        --enable-perf) ENABLE_PERF="$2"; shift 2 ;;
        --run-unit) RUN_UNIT="$2"; shift 2 ;;
        --run-stress) RUN_STRESS="$2"; shift 2 ;;
        --run-bench) RUN_BENCH="$2"; shift 2 ;;
        --perf-threshold) PERF_THRESHOLD_MS="$2"; shift 2 ;;
        --run-long-stress) RUN_LONG_STRESS="$2"; shift 2 ;;
        --fail-on-bench-exceed) FAIL_ON_BENCH_EXCEED=1; shift ;;
        -h|--help) usage; exit 0 ;;
        *) log_error "Unknown option: $1"; usage; exit 1 ;;
    esac
done

cd "$PROJECT_ROOT"

log_info "🧪 TurnTabby Comprehensive Test Runner"
log_info "======================================"
log_info "Build Type: $BUILD_TYPE"
log_info "Stress Testing: $ENABLE_STRESS"
log_info "Performance Benchmarking: $ENABLE_PERF"
log_info "Run Unit Tests: $RUN_UNIT"
log_info "Run Stress Tests: $RUN_STRESS"
log_info "Run Benchmarks: $RUN_BENCH"
log_info "Perf Threshold: ${PERF_THRESHOLD_MS}ms"
log_info "Long Stress: $RUN_LONG_STRESS"
log_info "Fail on Bench Exceed: $FAIL_ON_BENCH_EXCEED"

# Build once with all requested features
log_info "🔨 Building project with testing features..."
mkdir -p build
cd build

CMAKE_FLAGS="-DCMAKE_BUILD_TYPE=$BUILD_TYPE -Wno-dev"
if [ "$ENABLE_STRESS" = "1" ]; then
    CMAKE_FLAGS="$CMAKE_FLAGS -DENABLE_THREAD_SAFETY_STRESS_TESTING=ON"
fi
if [ "$ENABLE_PERF" = "1" ]; then
    CMAKE_FLAGS="$CMAKE_FLAGS -DENABLE_PERFORMANCE_BENCHMARKING=ON"
fi

cmake .. $CMAKE_FLAGS
cmake --build . --config $BUILD_TYPE --parallel $(sysctl -n hw.logicalcpu 2>/dev/null || echo 4) --target UnitTests

log_success "Build completed successfully!"

# Set environment variables
export TURN_TABBY_PERF_THRESHOLD_MS="$PERF_THRESHOLD_MS"
export TURN_TABBY_RUN_LONG_STRESS="$RUN_LONG_STRESS"
export TURN_TABBY_RUN_PERF_REGRESSION=1

# Run tests
# JUCE console apps are built to tests/UnitTests_artefacts/
TEST_EXE="./tests/UnitTests_artefacts/$BUILD_TYPE/UnitTests"

echo "Looking for test executable at: $TEST_EXE"
echo "Current directory: $(pwd)"
ls -la tests/UnitTests_artefacts/$BUILD_TYPE/ 2>/dev/null || echo "tests/UnitTests_artefacts/$BUILD_TYPE/ not found"
find . -name "*UnitTests*" -type f 2>/dev/null | head -5 || echo "No UnitTests files found"

if [ ! -f "$TEST_EXE" ]; then
    log_error "Test executable not found: $TEST_EXE"
    exit 1
fi

# Unit tests
if [ "$RUN_UNIT" = "1" ]; then
    log_info "🏃 Running unit tests..."
    $TEST_EXE --exclude-category="ThreadSafetyStressTests" --exclude-category="PerformanceBenchmarks"
    log_success "Unit tests completed!"
fi

# Stress tests
if [ "$RUN_STRESS" = "1" ]; then
    if [ "$ENABLE_STRESS" = "1" ]; then
        log_info "🧵 Running thread safety stress tests..."
        $TEST_EXE --category="ThreadSafetyStressTests"
        log_success "Stress tests completed!"
    else
        log_warning "Skipping stress tests (not enabled in build)"
    fi
fi

# Benchmarks
if [ "$RUN_BENCH" = "1" ]; then
    if [ "$ENABLE_PERF" = "1" ]; then
        log_info "📊 Running performance benchmarks..."
        $TEST_EXE --category="PerformanceBenchmarks"
        log_success "Benchmarks completed!"

        # Check thresholds if requested
        if [ "$FAIL_ON_BENCH_EXCEED" = "1" ]; then
            log_info "🚨 Checking benchmark thresholds..."
            
            # Find the latest performance results CSV
            RESULTS_DIR="$PROJECT_ROOT/performance_results"
            LATEST_CSV=$(ls -t "$RESULTS_DIR"/*.csv 2>/dev/null | head -1)
            THRESHOLDS_FILE="$SCRIPT_DIR/benchmark-thresholds.conf"
            
            if [ -n "$LATEST_CSV" ] && [ -f "$THRESHOLDS_FILE" ]; then
                log_info "Checking benchmark durations against thresholds from $THRESHOLDS_FILE"
                
                # Load thresholds from config file and check against CSV
                awk -F',' '
                NR==1 {next}  # Skip header in CSV
                FNR==NR && /^[^#]/ {  # Load config file (skip comments)
                    split($0, parts, "=")
                    thresholds[parts[1]] = parts[2]
                    next
                }
                $1 in thresholds {  # Check CSV rows
                    duration = $3
                    if (duration > thresholds[$1]) {
                        print "❌ FAIL: " $1 " exceeded threshold (" duration "us > " thresholds[$1] "us)"
                        failed=1
                    }
                }
                END {if (failed) exit 1}
                ' "$THRESHOLDS_FILE" "$LATEST_CSV"
                
                if [ $? -eq 0 ]; then
                    log_success "All benchmarks within thresholds"
                else
                    log_error "Performance regression detected! Failing build."
                    log_info "💡 To update thresholds for intentional changes:"
                    log_info "   1. Edit scripts/benchmark-thresholds.conf"
                    log_info "   2. Update the values for affected benchmarks"
                    log_info "   3. Commit and push the changes"
                    exit 1
                fi
            else
                if [ ! -f "$THRESHOLDS_FILE" ]; then
                    log_warning "Thresholds config file not found: $THRESHOLDS_FILE"
                else
                    log_warning "No CSV found for threshold check"
                fi
            fi
        fi
    else
        log_warning "Skipping benchmarks (not enabled in build)"
    fi
fi

log_success "All requested tests completed successfully! 🎉"