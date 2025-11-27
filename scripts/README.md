# Scripts

This folder contains helper scripts used for building, testing, benchmarking, and working with the TurnTabby repository.

This README lists all available scripts, with short descriptions and example invocations. For more advanced developer documentation see `docs/dev/*.md`.

## Usage note

- All scripts assume a POSIX shell (`bash`/`zsh`); TurnTabby dev environments use `zsh` as the default.
- Make scripts executable as needed: `chmod +x scripts/<script>`.

## Script catalog (alphabetical)

- `bench-atom4.sh`
  - Run the Atom4 memcpy vs interpolation microbenchmark described in `docs/dev/bench-atom4.md`.
  - Example: `./scripts/bench-atom4.sh --runs 100`
- `bench_resample.cpp`
  - C++ microbenchmark source used by `benchmark.sh`.
- `benchmark-thresholds.conf`
  - Configuration for `benchmark.sh` thresholds used by CI and local runs.
- `benchmark.sh`
  - Run performance benchmarks from the repo. Supports `--fail-on-exceed-thresholds` to fail on regressions, and runs Release performance builds by default.
  - Example: `./scripts/benchmark.sh --fail-on-exceed-thresholds`
- `build.sh`
  - Main build script (Release default): supports `--debug` / `-g`, `--asan` / `-a` (enables AddressSanitizer in a separate build dir), `--build-type` / `-t`, `--build-dir` / `-d`, `--ui-debug` / `--enable-ui-debug`, `--help`.
  - Note: this script uses your machine's logical CPU count for parallelism and doesn't take a `--jobs` flag.
  - Example: `./scripts/build.sh --debug`
- `ci_check_precalc_debug.sh`
  - CI helper script to validate precalc debug artifacts and dump traces.
- `clean.sh`
  - Clean the `build/` directory.
  - Example: `./scripts/clean.sh`
- `code-stats.sh`
  - Report codebase statistics (LOC, top files, artifact sizes, and binary text/data/bss memory estimates).
  - Example: `./scripts/code-stats.sh`
- `docs.sh`
  - Helper to build or open docs. See `generate_docs.sh` for the actual build.
- `find_todos.sh`
  - Scans the codebase for TODOs and FIXME comments, summarizes the TODOs for triage.
  - Example: `./scripts/find_todos.sh`
- `generate_docs.sh`
  - Generate Doxygen/Markdown developer docs. See `docs/` for details.
  - Example: `./scripts/generate_docs.sh` (writes to `docs/doxydocs`)
- `run-all-tests.sh`
  - Runs the full test suite, with optional flags to enable benchmarks or stress tests.
  - Example: `./scripts/run-all-tests.sh --run-bench --run-stress`
- `run-tests.sh`
  - Run JUCE unit tests with flexible options: `--build-first` (`-b`), `--build-if-missing` (`-m`), `--debug`/`--release` (or `--build-type` / `-t`), `--filter`, `--perf-threshold`, `--run-long-stress`, `--run-perf-regression`, `--extended-edge-cases`, and `--env KEY=VALUE` for arbitrary exports. The extended flag reconfigures builds with `--edge-tests` and runs only the `extended` category.
  - NOTE: this script expects to run from the project root. Some environments may use the `PROJECT_HOME` environment variable — running from the repo root ensures correct path resolution.
  - Example: `./scripts/run-tests.sh --build-if-missing -g --filter "PluginEditor View Mode Tests"`
- `run.sh`
  - Helper wrapper to run the Standalone app for the current build type. Supports `--build-first`, `--build-if-missing`, `--asan`, allocator guards, and log capture via `--log-run` / `--log-file` (tees stdout/stderr into `build/turntabby_run.log` by default).
  - Example: `./scripts/run.sh --build-if-missing -g --log-run`
- `stress-test.sh`
  - Launches thread-safety stress tests (concurrent UI/audio thread validation). See `docs/dev/THREAD_SAFETY_STRESS_TESTING.md` for usage.
  - Example: `./scripts/stress-test.sh --duration 30 --jobs 8`
- `xml_to_markdown.py`
  - Small helper to convert XML or `size` outputs to Markdown-friendly tables for inclusion in `docs/`.

## Common flags (supported across many scripts)

- `--build-first` / `-b` — Start by building the current target before running.
- `--build-if-missing` / `-m` — Build only if missing artifacts are not present.
- `--debug` / `-g` — Run tests or build in debug mode (more logging; larger artifacts).
- `--build-type <Debug|Release>` / `-t` — Select build type.
- `--filter` — Test or benchmark filter (pattern) to run a subset of tests.

## Notes & tips

- Many scripts produce build artifacts under `build/src/TurnTabby_artefacts/{Debug,Release}`, logs in `build/`, and docs under `docs/doxydocs`.
- Prefer `--build-if-missing` during iterative development to avoid expensive rebuilds.
- Use the `--debug` flag (optionally with `--precalc-debug`, `--debug-visualizations`, etc.) only when you need the heavy notation/visualization tooling; they significantly increase build times.
- See `docs/dev/` for deeper guidance on stress/benchmark/debugging scripts:
  - `docs/dev/PERFORMANCE_BENCHMARKING.md` (benchmarks)
  - `docs/dev/THREAD_SAFETY_STRESS_TESTING.md` (stress tests)
  - `docs/dev/DEBUG_PRECALC.md` (precalc debug)
  - `docs/dev/EDGE_CASE_VALIDATION.md` (edge-case testing)

If you want to add usage examples for particular scripts (or add `--help` output to the scripts themselves), mention which ones should be updated in the next PR.
