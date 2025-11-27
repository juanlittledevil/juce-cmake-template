#!/bin/bash
set -e

echo "🏃 Running TurnTabby Unit Tests (assuming build is current)..."
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

export TURN_TABBY_RUN_LONG_STRESS="${TURN_TABBY_RUN_LONG_STRESS:-0}"
export TURN_TABBY_RUN_PERF_REGRESSION="${TURN_TABBY_RUN_PERF_REGRESSION:-0}"
if [[ -n "${TURN_TABBY_PERF_THRESHOLD_MS:-}" ]]; then
    export TURN_TABBY_PERF_THRESHOLD_MS
fi

ENV_SUMMARY_PRINTED=0
print_env_summary() {
    if [[ "$ENV_SUMMARY_PRINTED" == "1" ]]; then
        return
    fi
    echo "Exported test envs:"
    echo "  TURN_TABBY_PERF_THRESHOLD_MS=${TURN_TABBY_PERF_THRESHOLD_MS:-<unset>}"
    echo "  TURN_TABBY_RUN_LONG_STRESS=${TURN_TABBY_RUN_LONG_STRESS}"
    echo "  TURN_TABBY_RUN_PERF_REGRESSION=${TURN_TABBY_RUN_PERF_REGRESSION}"
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
    TURNTABBY_SKIP_OVERWRITE_TEST=1 "$binary" "${exec_args[@]}"
}

run_tests_from_binary() {
    local binary="$1"
    if [[ "$EXTENDED_EDGE_CASES" == "1" ]]; then
        run_extended_tests "$binary"
        return
    fi
    print_env_summary
    if [ -n "$RUN_FILTER" ]; then
        TURNTABBY_SKIP_OVERWRITE_TEST=1 "$binary" --reporter console --filter="$RUN_FILTER" "${FORWARD_ARGS[@]}"
    else
        TURNTABBY_SKIP_OVERWRITE_TEST=1 "$binary" --reporter console "${FORWARD_ARGS[@]}"
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
        --perf-threshold)
            TURN_TABBY_PERF_THRESHOLD_MS="$2"
            export TURN_TABBY_PERF_THRESHOLD_MS
            shift; shift
            ;;
        --perf-threshold=*)
            TURN_TABBY_PERF_THRESHOLD_MS="${key#*=}"
            export TURN_TABBY_PERF_THRESHOLD_MS
            shift
            ;;
        --run-long-stress|-s)
            TURN_TABBY_RUN_LONG_STRESS=1
            export TURN_TABBY_RUN_LONG_STRESS
            shift
            ;;
        --run-perf-regression)
            TURN_TABBY_RUN_PERF_REGRESSION=1
            export TURN_TABBY_RUN_PERF_REGRESSION
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
  --perf-threshold=<ms>       Export TURN_TABBY_PERF_THRESHOLD_MS for perf asserts.
  --run-long-stress|-s        Export TURN_TABBY_RUN_LONG_STRESS=1.
  --run-perf-regression       Export TURN_TABBY_RUN_PERF_REGRESSION=1.
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
    path="${BUILD_DIR}/tests/UnitTests_artefacts/${BUILD_TYPE}/UnitTests"
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

    debug_path="${BUILD_DIR}/tests/UnitTests_artefacts/Debug/UnitTests"
    release_path="${BUILD_DIR}/tests/UnitTests_artefacts/Release/UnitTests"

    if [ -f "$debug_path" ] && [ -f "$release_path" ]; then
        if [[ "${DEBUG_BUILD:-0}" == "1" ]]; then
            BUILD_TYPE="Debug"
        else
            BUILD_TYPE="Release"
        fi
    elif [ -f "$release_path" ]; then
        BUILD_TYPE="Release"
    elif [ -f "$debug_path" ]; then
        BUILD_TYPE="Debug"
    else
        BUILD_TYPE=""
    fi

    if [ -n "$BUILD_TYPE" ]; then
        path="${BUILD_DIR}/tests/UnitTests_artefacts/${BUILD_TYPE}/UnitTests"
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
