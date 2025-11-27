# Tests

This folder contains the template's unit tests and a concise manual for contributors.

Overview

- Tests use JUCE's UnitTest framework.
- The repository follows a scripts-first workflow; prefer `./scripts/build.sh` / `./scripts/run-tests.sh` over ad-hoc helper scripts.

Quick commands

- Run project tests (fast — good for local development):

```bash
./scripts/run-tests.sh --category project
```

- Run the entire test-suite (slow — full verification):

```bash
./scripts/run-tests.sh --all
```

- CI example — build once, Release, run full suite:

```bash
./scripts/run-tests.sh --build-first --build-type Release --all
```

Conventions

- Put tests in `tests/` and keep focused, fast tests in the `project` category so `./scripts/run-tests.sh` can run them by default.

Example

```cpp
class PluginBasicTests : public juce::UnitTest
{
public:
    PluginBasicTests() : juce::UnitTest("Plugin Basic Tests", "project") {}
    void runTest() override { beginTest("Minimal example"); expect(true); }
};

static PluginBasicTests pluginBasicTests;
```

Running in an IDE (VS Code)

- Use CMake Tools to configure and build the UnitTests target, or run the test binary produced by the scripts. Typical places for the test binary:

```txt
build/tests/UnitTests
build/tests/UnitTests_artefacts/<Debug|Release>/UnitTests
```

NOTE: The top-level CMake configuration now exports a compile_commands.json by default (this helps the C/C++ extension in VS Code find the correct include paths and compile flags for test sources).

If you reconfigure or change build folders and need to refresh the IDE database, re-run a CMake configure/build (or run `cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON`) and then use the C/C++ extension command "C/C++: Reset IntelliSense Database".

## Warnings as errors for repo source

This template has a project-scoped option to treat warnings-as-errors for the codebase to avoid leaving behind warning clutter.

- Option: `ENFORCE_OUR_WARNINGS` (default: OFF) — when enabled, build targets for this repository (plugin and tests) will be compiled with `-Werror -Wall -Wextra -Wpedantic` (or `/WX /W4` on MSVC).
- Opt-out: pass `-DENFORCE_OUR_WARNINGS=OFF` when configuring CMake if you'd like to disable this for a session.

Examples:

```bash
# Configure with our warnings enforced (default)
cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

# Configure and disable enforcement for this configure
cmake -S . -B build -DENFORCE_OUR_WARNINGS=OFF
```

Best practices

- Keep tests unit-sized and deterministic.
- Reserve heavy or long-running tests for separate categories (don't include them in `project`).
- Use descriptive failure messages with JUCE's `expect` macros.

Further reading

- `./scripts/README.md` — script usage and runner options
- `docs/index.md` — documentation landing page (template-standard)
