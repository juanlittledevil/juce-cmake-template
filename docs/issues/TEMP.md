# script & IDE: export compile DB by default + enforce warnings-as-errors (configurable)

## Summary

- Export CMake's `compile_commands.json` by default so IDEs (VS Code/C/C++ extension) automatically get accurate compile flags and include paths.
- Add `ENFORCE_OUR_WARNINGS` (default OFF) + `OUR_WARNING_FLAGS` so repository source is built with warnings-as-errors (target-scoped).
- Apply warnings-as-errors only to repo targets (e.g., `JuceTemplate`, `UnitTests`) so third‑party code (JUCE) is unaffected.
- Add a script-level control in `scripts/build.sh`:
  - `--warn-as-error [on|off]` (or `--no-warn-as-error`)
  - Precedence: CLI > WARN_AS_ERROR env var > default OFF
  - The script passes this through to CMake as `-DENFORCE_OUR_WARNINGS=...`.
- Documented behavior in `tests/README.md` and `scripts/README.md`. Added `.gitignore` rules to prevent committing workspace compile DB files.

---

## Why this change

- Improves developer experience in editors by ensuring Intellisense receives the correct compile flags.
- Enforces a clean code baseline by treating repository warnings as errors — prevents new warnings creeping in while leaving third-party code alone.
- Keeps the behavior configurable and reversible for contributors / CI.

---

## Files changed (high-level)

- `CMakeLists.txt` (top-level) — generate `compile_commands.json` by default and add `ENFORCE_OUR_WARNINGS` / `OUR_WARNING_FLAGS`.
- `src/CMakeLists.txt` & `tests/CMakeLists.txt` — apply target-scoped compile options when `ENFORCE_OUR_WARNINGS` is enabled.
- `scripts/build.sh` — add `--warn-as-error [on|off]`, `--no-warn-as-error` and pass value to CMake.
- `scripts/README.md` & `tests/README.md` — document new behavior and how to opt out.
- `.gitignore` — ignore workspace `compile_commands.json` and `.vscode/compile_commands.json`.
- `.vscode/launch.json` — updated local launch configs to use template artifact paths.

---

## How to test locally

1. Default (enforcement ON, compile DB generated):

    ```bash
    # configure (default)
    cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=Debug
    # inspect compile DB for our target flags
    jq -r '.[] | select(.file|endswith("src/PluginProcessor.cpp")) | .command' build/compile_commands.json | head -n 1
    ```

    You should see `-Werror -Wall -Wextra -Wpedantic` (or `/WX /W4` on MSVC) in the command.

2. Disable enforcement via env:

    ```bash
    export WARN_AS_ERROR=off
    ./scripts/build.sh  # or cmake -DENFORCE_OUR_WARNINGS=OFF ...
    ```

3. CLI override (highest precedence):

    ```bash
    WARN_AS_ERROR=off ./scripts/build.sh --warn-as-error on
    # or:
    ./scripts/build.sh --no-warn-as-error   # disable
    ```

---

## Checklist (manual)

- [ ] Verify CI / Mac / Linux builds are green with the new defaults.
- [x] `compile_commands.json` is generated during configure (verified locally).
- [x] `-Werror` (or `/WX`) is present for repository targets when enforcement is ON (verified).
- [x] Script flag & env precedence works (CLI > env > default) (verified).

---

## Notes for reviewers

- The enforcement only applies to repository targets. Third‑party or JUCE module targets are not modified.
- If you prefer enforcement OFF project-wide for some CI job, pass `-DENFORCE_OUR_WARNINGS=OFF` to configure or use the script `--no-warn-as-error` flag.
- The `.vscode/launch.json` edits are local convenience defaults (template-style paths) and can be overwritten by the project setup script if needed.
