#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

printf "=== Project codebase stats ===\n"

# Detect PROJECT_NAME from CMakeLists.txt or fall back to root folder name
PROJECT_NAME=$(grep "^project(" CMakeLists.txt 2>/dev/null | sed 's/project(\([^ ]*\).*/\1/' | head -1)
if [[ -z "$PROJECT_NAME" ]]; then
  PROJECT_NAME=$(basename "$ROOT_DIR")
fi

CODE_DIRS=(src include tests)
EXTS=("cpp" "c" "mm" "h" "hpp" "m")

human_readable() {
  awk -v n="$1" 'function hr(x){ split("B KB MB GB TB", u); i=1; while(x>=1024 && i<5){ x/=1024; i++ } printf("%.2f %s", x, u[i]); } BEGIN{ print hr(n) }'
}

printf "\n-- Lines of code (by extension, src/include/tests) --\n"
total_lines=0
for ext in "${EXTS[@]}"; do
  n=$(find "${CODE_DIRS[@]}" -type f -name "*.$ext" 2>/dev/null | xargs -r wc -l 2>/dev/null | tail -n1 | awk '{print $1}')
  if [[ -n "$n" && "$n" != "0" ]]; then
    printf "%s: %s\n" "$ext" "$n"
    total_lines=$((total_lines + n))
  fi
done
printf "TOTAL (C/C++/ObjC lines in src/include/tests): %s\n" "$total_lines"

printf "\n-- Top 10 source files by LOC (in src/include) --\n"
find src include -type f \
  \( -name '*.[ch]pp' -o -name '*.cpp' -o -name '*.c' -o -name '*.mm' -o -name '*.h' -o -name '*.hpp' \) \
  -print | xargs -r wc -l 2>/dev/null | sort -nr | head -n 10

printf "\n-- Build artifacts size --\n"
if [[ -d build ]]; then
  printf "Build dir size: %s\n" "$(du -sh build | awk '{print $1}')"
else
  printf "No 'build' directory found; run ./scripts/build.sh first to generate artifacts.\n"
fi

printf "\n-- Key built artifacts (Release/Debug) --\n"
for cfg in Debug Release; do
  ARTDIR="build/src/${PROJECT_NAME}_artefacts/${cfg}"
  if [[ -d "$ARTDIR" ]]; then
    printf "Artifacts for %s:\n" "$cfg"
    find "$ARTDIR" -maxdepth 2 -type f -exec du -h {} + 2>/dev/null | sort -hr | head -n 20
  else
    printf "  No artifacts found for %s\n" "$cfg"
  fi
done

printf "\n-- Memory section estimates (text/data/bss) for binaries --\n"
SIZE_CMD=$(command -v size || true)
if [[ -n "$SIZE_CMD" ]]; then
  declare -a BIN_PATHS
  if [[ -f "build/tests/UnitTests_artefacts/Debug/UnitTests" ]]; then
    BIN_PATHS+=("build/tests/UnitTests_artefacts/Debug/UnitTests")
  fi
  if [[ -f "build/tests/UnitTests_artefacts/Release/UnitTests" ]]; then
    BIN_PATHS+=("build/tests/UnitTests_artefacts/Release/UnitTests")
  fi
  for cfg in Debug Release; do
    APP="$ROOT_DIR/build/src/${PROJECT_NAME}_artefacts/${cfg}/Standalone/${PROJECT_NAME}.app/Contents/MacOS/${PROJECT_NAME}"
    if [[ -x "$APP" ]]; then
      BIN_PATHS+=("$APP")
    fi
  done

  if [[ ${#BIN_PATHS[@]} -eq 0 ]]; then
    printf "No binaries found for 'size' measurement; build the artifacts first to get section sizes.\n"
  else
    for bin in "${BIN_PATHS[@]}"; do
      [[ -f "$bin" ]] || continue
      printf "\n%s\n" "$bin"
      linux_size=$(size "$bin" 2>/dev/null || true)
      if [[ -n "$linux_size" && $(echo "$linux_size" | awk '/^[[:space:]]*[0-9]/{print 1; exit}') == 1 ]]; then
        num_line=$(echo "$linux_size" | awk '/^[[:space:]]*[0-9]/{line=$0} END{print line}')
        text=$(echo "$num_line" | awk '{print $1}')
        data=$(echo "$num_line" | awk '{print $2}')
        bss=$(echo "$num_line" | awk '{print $3}')
        text=${text:-0}
        data=${data:-0}
        bss=${bss:-0}
        sum=$((text + data + bss))
        printf "  text: %s bytes, data: %s bytes, bss: %s bytes, approx memory: %s\n" "$text" "$data" "$bss" "$(human_readable $sum)"
        continue
      fi
      out=$(size -m "$bin" 2>/dev/null || true)
      if [[ -n "$out" ]]; then
        text_total=$(echo "$out" | awk '/Segment __TEXT:/{flag=1} flag && /total/{print $2; flag=0}' | tail -n1)
        data_tot=$(echo "$out" | awk '/Segment __DATA:/{flag=1} flag && /total/{print $2; flag=0}' | tail -n1)
        data_const=$(echo "$out" | awk '/Segment __DATA_CONST:/{flag=1} flag && /total/{print $2; flag=0}' | tail -n1)
        text_total=${text_total:-0}
        data_tot=${data_tot:-0}
        data_const=${data_const:-0}
        sum=$((text_total + data_tot + data_const))
        printf "  text: %s bytes, data: %s bytes, data_const: %s bytes, approx memory: %s\n" "$text_total" "$data_tot" "$data_const" "$(human_readable $sum)"
      else
        filesize=$(stat -c%s "$bin" 2>/dev/null || stat -f%z "$bin" 2>/dev/null || echo 0)
        printf "  (fallback) file size: %s\n" "$(human_readable $filesize)"
      fi
    done
  fi
else
  printf "'size' tool is not available on this system; skipping text/data/bss report.\n"
fi

printf "\n-- Repo summary --\n"
printf "Total files (src/include/tests only): %s\n" "$(git ls-files src include tests 2>/dev/null | wc -l | awk '{print $1}')"
printf "Total lines across src/include/tests: %s\n" "$(git ls-files src include tests 2>/dev/null | xargs -r wc -l 2>/dev/null | tail -n1 | awk '{print $1}')"
test_count=$(find tests -name "*.cpp" -type f 2>/dev/null | wc -l | awk '{print $1}')
unittest_count=$(grep -R "class .* : public juce::UnitTest" tests src 2>/dev/null | wc -l | awk '{print $1}')
printf "Total test files: %s (UnitTest classes: %s)\n" "$test_count" "$unittest_count"
printf "Git status:\n"
git status --porcelain | wc -l | awk '{print "  Modified/Staged: " $1}'

printf "\nDone.\n"
