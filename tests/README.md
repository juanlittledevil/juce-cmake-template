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

Best practices

- Keep tests unit-sized and deterministic.
- Reserve heavy or long-running tests for separate categories (don't include them in `project`).
- Use descriptive failure messages with JUCE's `expect` macros.

Further reading

- `./scripts/README.md` — script usage and runner options
- `docs/index.md` — documentation landing page (template-standard)
