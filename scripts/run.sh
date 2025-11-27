#!/usr/bin/env bash
set -euo pipefail

# Re-exec under bash if this is not a bash instance (helps when running on zsh/sh)
if [ -z "${BASH_VERSION:-}" ]; then
  exec /usr/bin/env bash "$0" "$@"
fi

# Detect if the script is being sourced (not executed) and refuse to run if so.
if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
  echo "This script should be executed (./scripts/run.sh), not sourced." >&2
  return 1 2>/dev/null || exit 1
fi

# Usage: ./run.sh [--asan | --build-dir DIR --build-type TYPE]
# Launches the standalone app from the requested build configuration.

if [[ -n "${PROJECT_HOME:-}" ]]; then
  ROOT_DIR="${PROJECT_HOME}"
else
  ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

# Try to detect the project name from CMakeLists.txt (fallback to directory name)
PROJECT_NAME="$(grep "^project(" "$ROOT_DIR/CMakeLists.txt" 2>/dev/null | sed 's/project(\([^ ]*\).*/\1/' | head -1)"
if [[ -z "$PROJECT_NAME" ]]; then
  PROJECT_NAME="$(basename "$ROOT_DIR")"
fi

BUILD_DIR="build"
BUILD_TYPE="Release"
ALLOC_GUARDS="OFF"
BUILD_FIRST="0"
BUILD_IF_MISSING="0"
LOGGING_ENABLED="0"
LOG_FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --asan)
      BUILD_DIR="build-asan"
      BUILD_TYPE="Debug"
      ;;
    --build-dir|-d)
      shift
      # Defensive: ensure value present and not another flag
      if [[ $# -gt 0 && "${1:0:1}" != "-" ]]; then
        BUILD_DIR="$1"
      else
        echo "⚠️  Missing or invalid value for --build-dir" >&2
        exit 1
      fi
      ;;
    --build-type|-t)
      shift
      # Defensive: ensure value present and not another flag
      if [[ $# -gt 0 && "${1:0:1}" != "-" ]]; then
        BUILD_TYPE="$1"
      else
        echo "⚠️  Missing or invalid value for --build-type" >&2
        exit 1
      fi
      ;;
    --debug|-g)
      BUILD_TYPE="Debug"
      ;;
    --alloc-guards)
      ALLOC_GUARDS="ON"
      ;;
    --build-first|-b)
      BUILD_FIRST="1"
      ;;
    --build-if-missing|-m)
      BUILD_IF_MISSING="1"
      ;;
    --log-run)
      LOGGING_ENABLED="1"
      ;;
    --log-file)
      shift
      # Ensure the provided value exists and isn't another flag
      if [[ $# -gt 0 && "${1:0:1}" != "-" ]]; then
        LOGGING_ENABLED="1"
        LOG_FILE="$1"
      else
        echo "⚠️  Missing or invalid value for --log-file" >&2
        exit 1
      fi
      ;;
    --log-file=*)
      LOGGING_ENABLED="1"
      LOG_FILE="${1#*=}"
      ;;
    --help|-h)
      cat <<EOF
Usage: ./scripts/run.sh [options]

Options:
  --asan            Launch the Debug build produced by ./scripts/build.sh --asan (build-asan dir).
  --build-dir DIR   Launch artifacts from a custom build directory.
  --build-type TYPE Launch a specific configuration (Release, Debug, etc.).
  --debug,-g        Shortcut for --build-type Debug.
  --alloc-guards    Enable malloc diagnostics (MallocScribble, MallocGuardEdges, MallocStackLogging).
  --build-first|-b  Attempt to build requested build-type before launching.
  --build-if-missing|-m  Build only if the requested build artifact is missing.
  --log-run         Tee stdout/stderr to build/run.log while running the app.
  --log-file PATH   Shortcut for --log-run with a custom log file (relative paths resolve within repo root).
  --help            Show this message and exit.
EOF
      exit 0
      ;;
    *)
      echo "⚠️  Unknown option: $1" >&2
      exit 1
      ;;
  esac
  shift
done

if [[ "$LOGGING_ENABLED" == "1" ]]; then
  if [[ -z "$LOG_FILE" ]]; then
    LOG_FILE="${BUILD_DIR}/run.log"
  fi
  if [[ "$LOG_FILE" != /* ]]; then
    LOG_FILE="$ROOT_DIR/${LOG_FILE}"
  fi
fi

APP_PATH="$ROOT_DIR/${BUILD_DIR}/src/${PROJECT_NAME}_artefacts/${BUILD_TYPE}/Standalone/${PROJECT_NAME}.app"

if [[ ! -d "$APP_PATH" ]]; then
  echo "Error: app not found at: $APP_PATH" >&2
  if [[ "${BUILD_FIRST}" == "1" ]] || [[ "${BUILD_IF_MISSING}" == "1" ]]; then
    echo "🔧 Requested build before launching; attempting to build ${BUILD_TYPE}..."
    ./scripts/build.sh --build-type "${BUILD_TYPE}"
  fi

  if [[ ! -d "$APP_PATH" ]]; then
    echo "Error: app not found at: $APP_PATH" >&2
    if [[ "$BUILD_DIR" == "build-asan" ]]; then
      echo "Make sure you've built the project with: ./scripts/build.sh --asan" >&2
    else
      echo "Make sure you've built the project with: ./scripts/build.sh --build-type ${BUILD_TYPE}" >&2
    fi
    exit 1
  fi
fi

APP_BUNDLE_NAME=$(basename "$APP_PATH")
APP_EXECUTABLE="$APP_PATH/Contents/MacOS/${APP_BUNDLE_NAME%.app}"

if [[ ! -x "$APP_EXECUTABLE" ]]; then
  echo "Error: Executable not found inside bundle: $APP_EXECUTABLE" >&2
  exit 1
fi

cd "$ROOT_DIR"
echo "Launching ${PROJECT_NAME} from: $ROOT_DIR (${BUILD_TYPE}, dir: ${BUILD_DIR})"
echo "Using artifact path: $APP_PATH"

declare -a LAUNCH_ENV=()
if [[ "$ALLOC_GUARDS" == "ON" ]]; then
  echo "🔒 Enabling malloc diagnostics (MallocScribble, MallocGuardEdges, MallocStackLogging)."
  LAUNCH_ENV+=("MallocScribble=1")
  LAUNCH_ENV+=("MallocGuardEdges=1")
  LAUNCH_ENV+=("MallocStackLogging=1")
fi

declare -a APP_CMD
if [[ ${#LAUNCH_ENV[@]} -gt 0 ]]; then
  echo "Environment overrides: ${LAUNCH_ENV[*]}"
  APP_CMD=(env "${LAUNCH_ENV[@]}" -- "$APP_EXECUTABLE")
else
  APP_CMD=("$APP_EXECUTABLE")
fi

if [[ "$LOGGING_ENABLED" == "1" ]]; then
  LOG_DIR="$(dirname "$LOG_FILE")"
  mkdir -p "$LOG_DIR"
  : > "$LOG_FILE"
  echo "📝 Logging stdout/stderr to: $LOG_FILE"
  "${APP_CMD[@]}" 2>&1 | tee -a "$LOG_FILE"
else
  "${APP_CMD[@]}"
fi