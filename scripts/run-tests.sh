#!/bin/bash
set -e

echo "🏃 Running unit tests (assuming build is current)..."
echo "==========================================================="

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ORIG_PWD="$(pwd)"
if [[ -n "${PROJECT_HOME:-}" ]]; then
    cd "${PROJECT_HOME}"
else
    cd "$ROOT_DIR"
fi

ENV_FILE="$ROOT_DIR/build-tests.env"
if [[ -f "$ENV_FILE" ]]; then
    echo "[env] Sourcing repo env defaults from $ENV_FILE"
    set -a
    # shellcheck disable=SC1090
    source "$ENV_FILE"
    set +a
fi

ENV_SUMMARY_PRINTED=0
print_env_summary() {
    if [[ "$ENV_SUMMARY_PRINTED" == "1" ]]; then
        return
    fi
    echo "Exported test envs:"
    echo "  (no template-specific long-stress environment variables)"
    ENV_SUMMARY_PRINTED=1
}

EXTENDED_SYMBOL="ExtendedEdgeCaseValidationTests"

has_extended_tests_symbol() {
    local binary="$1"
    if command -v nm >/dev/null 2>&1; then
        nm "$binary" 2>/dev/null | grep -q "$EXTENDED_SYMBOL"
    else
        strings "$binary" 2>/dev/null | grep -q "$EXTENDED_SYMBOL"
    fi
}

ensure_extended_tests_available() {
    local binary="$1"
    if has_extended_tests_symbol "$binary"; then
        return
    fi
    echo "❌ Extended edge case tests were requested, but $binary does not contain $EXTENDED_SYMBOL." >&2
    echo "   Rebuild via ./scripts/build.sh --edge-tests (or pass --extended-edge-cases with --build-first/--build-if-missing)." >&2
    exit 2
}

run_extended_tests() {
    local binary="$1"
    ensure_extended_tests_available "$binary"
    print_env_summary
    local -a exec_args=(--reporter console --category="extended")
    if [ -n "$RUN_FILTER" ]; then
        exec_args+=(--filter="$RUN_FILTER")
    fi
    exec_args+=("${FORWARD_ARGS[@]}")
    SKIP_OVERWRITE_TEST=1 "$binary" "${exec_args[@]}"
}

run_tests_from_binary() {
    local binary="$1"
    if [[ "$EXTENDED_EDGE_CASES" == "1" ]]; then
        run_extended_tests "$binary"
        return
    fi
    print_env_summary
    if [ -n "$RUN_FILTER" ]; then
        SKIP_OVERWRITE_TEST=1 "$binary" --reporter console --filter="$RUN_FILTER" "${FORWARD_ARGS[@]}"
    else
        SKIP_OVERWRITE_TEST=1 "$binary" --reporter console "${FORWARD_ARGS[@]}"
    fi
}

run_build_for_tests() {
    local target_type="$1"
    if [[ -z "$target_type" ]]; then
        target_type="Release"
    fi

    local -a extra_build_args=()
    if [[ "$EXTENDED_EDGE_CASES" == "1" ]]; then
        extra_build_args+=(--edge-tests)
    fi

    # Support additional build switches used for the consolidated --all runner
    if [[ "${ENABLE_THREAD_STRESS:-0}" == "1" ]]; then
        extra_build_args+=(--thread-stress-tests)
    fi
    # Benchmarks/perf disabled in template by default — noop here

    if [[ "$REQUESTED_ASAN" == "1" ]]; then
        ./scripts/build.sh --asan "${extra_build_args[@]}"
    else
        if [[ "$BUILD_DIR" != "build" ]]; then
            ./scripts/build.sh --build-type "$target_type" --build-dir "$BUILD_DIR" "${extra_build_args[@]}"
        else
            ./scripts/build.sh --build-type "$target_type" "${extra_build_args[@]}"
        fi
    fi
}

RUN_FILTER=""
BUILD_TYPE=""
BUILD_DIR="build"
BUILD_FIRST="0"
BUILD_IF_MISSING="0"
EXTENDED_EDGE_CASES="0"
REQUESTED_ASAN="0"
ALL_MODE="0"
ENABLE_THREAD_STRESS="1"
RUN_UNIT="1"
RUN_STRESS="1"
# RUN_LONG_STRESS removed (long-stress support removed from template)
declare -a FORWARD_ARGS=()
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --filter)
            RUN_FILTER="$2"
            shift; shift
            ;;
        --filter=*)
            RUN_FILTER="${key#*=}"
            shift
            ;;
        --build-type|-t)
            BUILD_TYPE="$2"
            shift; shift
            ;;
        --build-type=*)
            BUILD_TYPE="${key#*=}"
            shift
            ;;
        --debug|-g)
            BUILD_TYPE="Debug"
            shift
            ;;
        --release)
            BUILD_TYPE="Release"
            shift
            ;;
        --build-dir|-d)
            BUILD_DIR="$2"
            shift; shift
            ;;
        --build-dir=*)
            BUILD_DIR="${key#*=}"
            shift
            ;;
        --asan)
            REQUESTED_ASAN="1"
            BUILD_DIR="build-asan"
            if [[ -z "$BUILD_TYPE" ]]; then
                BUILD_TYPE="Debug"
            fi
            shift
            ;;
        --build-first|-b)
            BUILD_FIRST="1"
            shift
            ;;
        --build-if-missing|-m)
            BUILD_IF_MISSING="1"
            shift
            ;;
        # --run-long-stress removed (not supported by generic template runner)
        --all)
            ALL_MODE="1"
            shift
            ;;
        --enable-stress)
            ENABLE_THREAD_STRESS="1"
            shift
            ;;
        --enable-stress=0|--enable-stress=1)
            ENABLE_THREAD_STRESS="${key#*=}"
            shift
            ;;
        --run-unit=0|--run-unit=1)
            RUN_UNIT="${key#*=}"
            shift
            ;;
        --run-stress=0|--run-stress=1)
            RUN_STRESS="${key#*=}"
            shift
            ;;
        --run-bench=0|--run-bench=1)
            # --run-bench ignored (benchmarks removed)
            shift
            ;;
        --env)
            if [[ "$2" == *=* ]]; then
                export "$2"
                shift 2
            else
                echo "--env requires KEY=VALUE" >&2
                exit 1
            fi
            ;;
        --env=*)
            pair="${key#*=}"
            if [[ "$pair" == *=* ]]; then
                export "$pair"
                shift
            else
                echo "--env requires KEY=VALUE" >&2
                exit 1
            fi
            ;;
        --extended-edge-cases|--extended-edge-tests|--edge-tests-only)
            EXTENDED_EDGE_CASES="1"
            shift
            ;;
        --help)
            cat <<EOF
Usage: $0 [options]

Options:
  --filter <pattern>          Run a subset of tests.
  --build-type|-t <type>      Choose Release/Debug/etc.
  --build-dir|-d <dir>        Use an alternate build directory.
  --debug|-g                  Shortcut for --build-type Debug.
  --release                   Shortcut for --build-type Release.
  --asan                      Run tests from build-asan dir (builds Debug ASAN if needed).
    --build-first|-b            Always rebuild before running tests.
  --build-if-missing|-m       Build only when UnitTests binary is absent.
    --extended-edge-cases       Build (if needed) with --edge-tests and run only the extended category.
    --run-long-stress|-s        (not supported in template)
    (benchmarks/perf are disabled in the template)
  --env KEY=VALUE             Export arbitrary env vars before running tests.
  --help                      Show this message and exit.
  --                          Forward remaining args directly to UnitTests binary.
EOF
            exit 0
            ;;
        --)
            shift
            while [[ $# -gt 0 ]]; do
                FORWARD_ARGS+=("$1")
                shift
            done
            break
            ;;
        *)
            FORWARD_ARGS+=("$key")
            shift
            ;;
    esac
done

if [ -n "$BUILD_TYPE" ]; then
    if [[ "$BUILD_FIRST" == "1" ]]; then
        echo "🔧 --build-first specified; building ${BUILD_TYPE} build before running tests..."
        run_build_for_tests "$BUILD_TYPE"
    fi
    # Try the canonical CMake test executable locations (modern template uses tests/UnitTests)
    candidate1="${BUILD_DIR}/tests/UnitTests"
    candidate2="${BUILD_DIR}/tests/UnitTests_artefacts/${BUILD_TYPE}/UnitTests"
    if [ -f "$candidate2" ]; then
        path="$candidate2"
    elif [ -f "$candidate1" ]; then
        path="$candidate1"
    else
        path="$candidate2"  # keep existing behavior; we'll error if not found
    fi
    if [ -f "$path" ]; then
        echo "Using $BUILD_TYPE build..."
        run_tests_from_binary "$path"
    else
        echo "❌ Requested build-type artifact not found at $path;"
        if [[ "$BUILD_FIRST" == "1" ]] || [[ "$BUILD_IF_MISSING" == "1" ]]; then
            echo "🔧 --build-first specified; attempting to build ${BUILD_TYPE}..."
            run_build_for_tests "$BUILD_TYPE"
            if [ -f "$path" ]; then
                echo "✅ Build produced artifact; running tests now..."
                run_tests_from_binary "$path"
                cd "$ORIG_PWD"
                exit 0
            else
                echo "❌ Build completed but the artifact was not found at $path; falling back to automatic detection..."
                BUILD_TYPE=""
            fi
        else
            echo "❌ Requested build-type artifact not found at $path; falling back to automatic detection..."
            BUILD_TYPE=""
        fi
    fi
fi

run_all_tests() {
    # Build once with the requested features and run multiple test categories
    if [[ -z "$BUILD_TYPE" ]]; then
        BUILD_TYPE="Release"
    fi

    echo "🔨 Building ${BUILD_TYPE} (single-build, testing features)..."
    run_build_for_tests "$BUILD_TYPE"

    path="${BUILD_DIR}/tests/UnitTests_artefacts/${BUILD_TYPE}/UnitTests"
    if [ ! -f "$path" ]; then
        echo "❌ UnitTests binary not found at: $path" >&2
        exit 1
    fi

    # long-stress support intentionally omitted in template

    # Unit tests (exclude stress category)
    if [[ "${RUN_UNIT}" == "1" ]]; then
        echo "🏃 Running unit tests (excluding stress)..."
        "$path" --exclude-category="ThreadSafetyStressTests"
    fi

    # Stress tests
    if [[ "${RUN_STRESS}" == "1" ]]; then
        if [[ "${ENABLE_STRESS}" == "1" ]]; then
            echo "🧵 Running thread-safety stress tests..."
            # long-stress is intentionally ignored by template runner
            "$path" --category="ThreadSafetyStressTests"
        else
            echo "⚠️  Skipping stress tests: not enabled in build"
        fi
    fi

    echo "🎉 All requested tests completed"
}

# If --all requested, run the consolidated pipeline
if [[ "${ALL_MODE}" == "1" ]]; then
    run_all_tests
    cd "$ORIG_PWD"
    exit 0
fi

if [ -z "$BUILD_TYPE" ]; then
    if [[ "$BUILD_FIRST" == "1" ]]; then
        echo "🔧 --build-first specified without a build-type; building the default build type..."
        if [[ "${DEBUG_BUILD:-0}" == "1" ]]; then
            echo "🔧 DEBUG_BUILD=1 detected; building Debug tests..."
            run_build_for_tests "Debug"
        else
            echo "🔧 Building Release (default) build..."
            run_build_for_tests "Release"
        fi
    fi
    if [[ "$BUILD_IF_MISSING" == "1" ]]; then
        if [[ ! -f "${BUILD_DIR}/tests/UnitTests_artefacts/Debug/UnitTests" ]] && [[ ! -f "${BUILD_DIR}/tests/UnitTests_artefacts/Release/UnitTests" ]]; then
            echo "🔧 --build-if-missing specified and no artifacts present; building default build type..."
            if [[ "${DEBUG_BUILD:-0}" == "1" ]]; then
                run_build_for_tests "Debug"
            else
                run_build_for_tests "Release"
            fi
        fi
    fi

    # Try both the newer build/tests/UnitTests binary and the older UnitTests_artefacts layout
    debug_path1="${BUILD_DIR}/tests/UnitTests"
    debug_path2="${BUILD_DIR}/tests/UnitTests_artefacts/Debug/UnitTests"
    release_path1="${BUILD_DIR}/tests/UnitTests"
    release_path2="${BUILD_DIR}/tests/UnitTests_artefacts/Release/UnitTests"

    if ([ -f "$debug_path1" ] || [ -f "$debug_path2" ]) && ([ -f "$release_path1" ] || [ -f "$release_path2" ]); then
        if [[ "${DEBUG_BUILD:-0}" == "1" ]]; then
            BUILD_TYPE="Debug"
        else
            BUILD_TYPE="Release"
        fi
    elif [ -f "$release_path1" ] || [ -f "$release_path2" ]; then
        BUILD_TYPE="Release"
    elif [ -f "$debug_path1" ] || [ -f "$debug_path2" ]; then
        BUILD_TYPE="Debug"
    else
        BUILD_TYPE=""
    fi

    if [ -n "$BUILD_TYPE" ]; then
        # Prefer the artefacts path but accept the top-level tests/UnitTests binary if present
        if [ -f "${BUILD_DIR}/tests/UnitTests_artefacts/${BUILD_TYPE}/UnitTests" ]; then
            path="${BUILD_DIR}/tests/UnitTests_artefacts/${BUILD_TYPE}/UnitTests"
        elif [ -f "${BUILD_DIR}/tests/UnitTests" ]; then
            path="${BUILD_DIR}/tests/UnitTests"
        else
            path="${BUILD_DIR}/tests/UnitTests_artefacts/${BUILD_TYPE}/UnitTests"
        fi
        echo "Using $BUILD_TYPE build..."
        run_tests_from_binary "$path"
    else
        echo "❌ UnitTests binary not found in ${BUILD_DIR}/tests/UnitTests_artefacts/Release/ or Debug/"
        echo "   Run ./scripts/build.sh first to build the tests."
        cd "$ORIG_PWD"
        exit 1
    fi
fi

cd "$ORIG_PWD"

echo
echo "✅ Test run complete!"
