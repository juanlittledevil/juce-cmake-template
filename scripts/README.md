# Scripts

This folder contains helper shell scripts for building, running and testing projects using the JUCE CMake template.

These are intended to be the canonical, script-first developer workflows for this template (preferred for reproducibility and CI).

This README lists available scripts, short descriptions and common usage patterns. For deeper developer documentation see `docs/dev/*.md` (if present).

## Usage notes

- These scripts assume a POSIX shell (`bash`/`zsh`). They should run on macOS and Linux. Some helpers use macOS-specific tools (like `open`) and will fall back to linux-flavored commands when available.
- Make scripts executable (if needed):

```bash
chmod +x scripts/*.sh
```

- The repo supports two workflows:
  - Script-first (recommended): prefer `scripts/` for reliable, cross-platform behavior and CI-friendly usage.
  - VS Code CMake Tools (advanced): Use the status-bar CMake buttons — remember targets only appear after an initial configure/build.

## Script catalog (alphabetical)

- `build.sh` — Main build script (Release default)
  - Common options: `--debug` / `-g`, `--asan` / `-a` (build-asan dir), `--build-type` / `-t`, `--build-dir` / `-d`, `--help`.
  - Convenience: auto-detects project name from `CMakeLists.txt` and prints artifact locations after build.
  - Example: `./scripts/build.sh --debug`
    - New flag: `--warn-as-error [on|off]` (default is disabled / OFF).
      - Example: `./scripts/build.sh --warn-as-error on` (enable warnings-as-errors for this configure)
      - Example: `./scripts/build.sh --warn-as-error off` (disable warnings-as-errors for this configure)
      - Alias: `--no-warn-as-error` to quickly disable enforcement.
- `clean.sh` — Clean helper
  - Removes local build directories; conservative by default (does not remove external or shared workspaces without explicit opt-in).
  - Example: `./scripts/clean.sh`
- `code-stats.sh`
  - Report codebase statistics (LOC, top files, artifact sizes, and binary text/data/bss memory estimates).
  - Example: `./scripts/code-stats.sh`
- `docs.sh`
  - Helper to open generated docs. See `generate_docs.sh` for the actual generation step.
- `find_todos.sh`
  - Scans the codebase for TODOs and FIXME comments, summarizes the TODOs for triage.
  - Example: `./scripts/find_todos.sh`
- `generate_docs.sh`
  - Generate Doxygen/Markdown developer docs. See `docs/` for details.
  - Example: `./scripts/generate_docs.sh` (writes to `docs/doxydocs`)
- `run-tests.sh` — Unified test runner (unit, stress)
  - Powerful and flexible test runner. Supported options include `--build-first` / `-b`, `--build-if-missing` / `-m`, `--build-type` / `-t`, `--filter`, `--extended-edge-cases`, `--asan` and `--env KEY=VALUE`.
  - By default the script will try to detect test suites declared in `tests/*.cpp` and only run those (project-local tests) — this keeps template runs fast and avoids running the full JUCE upstream tests during quick developer iterations. Project tests are run under the `project` category; you can override this with `--category <name>` or request `--all` to run the entire test-suite (unit + stress/extended categories).
  - NOTE: run from the repository root (or set `PROJECT_HOME`) for path correctness.
  - Example: `./scripts/run-tests.sh --build-if-missing -g --filter "Editor"`
- `run.sh`
  - Helper wrapper to run the Standalone app for the current build type. Supports `--build-first`, `--build-if-missing`, `--asan`, allocator guards, and log capture via `--log-run` / `--log-file` (tees stdout/stderr into `build/run.log` by default).
  - Example: `./scripts/run.sh --build-if-missing -g --log-run`

## Common flags (supported across many scripts)

- `--build-first` / `-b` — Start by building the current target before running.
- `--build-if-missing` / `-m` — Build only if missing artifacts are not present.
- `--debug` / `-g` — Run tests or build in debug mode (more logging; larger artifacts).
- `--build-type <Debug|Release>` / `-t` — Select build type.
- `--filter` — Test or benchmark filter (pattern) to run a subset of tests.

## Notes & tips

- Many scripts produce build artifacts under `build/src/<project>_artefacts/{Debug,Release}` (or a similarly named artifacts folder), logs in `build/`, and docs under `docs/doxydocs`.
- Prefer `--build-if-missing` during iterative development to avoid expensive rebuilds.
-- Use the `--debug` flag (optionally with `--debug-visualizations`, etc.) only when you need heavy debug/visualization tooling; these options can significantly increase build times.
- See `docs/dev/` for deeper guidance on stress/benchmark/debugging scripts:
  - (performance benchmarking docs removed from template)
  - `docs/dev/THREAD_SAFETY_STRESS_TESTING.md` (stress tests)
  - (project-specific debug documents may be present under docs/dev/)
  - `docs/dev/EDGE_CASE_VALIDATION.md` (edge-case testing)

If you want to add usage examples for particular scripts (or expand `--help` output), tell me which scripts you want to document richer and I’ll add them.

---

## Migration notes (ported scripts → Template)

These scripts were ported from an example project and adapted to be template-generic. Suggested next steps (handled in separate, small PRs):

1. `run-all-tests.sh` behavior has been merged into `run-tests.sh --all` and the legacy script removed.
2. Generalize `run.sh` `build-artifact` detection using project-derived names rather than fixed application names.
3. Make `clean.sh` conservative and local-only by default while allowing opt-in for broader cleanup.

If you'd like, I can implement the above one-step-at-a-time after you review this README.
