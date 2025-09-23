# VS Code Configuration

This directory contains VS Code-specific configuration files for the JUCE CMake template.

## Files

- **`c_cpp_properties.json`** - C++ IntelliSense configuration
- **`launch.json`** - Debug configurations for standalone app and unit tests
- **`tasks.json`** - Build and test tasks

## Debug Configurations

### Debug Standalone App

Launches the standalone application under the debugger.

### Debug Unit Tests

Runs the unit tests under the debugger.

### Attach to Process

Allows you to attach the debugger to a running process.

## Project Setup for New Projects

When copying this template to create a new project:

1. **Use the setup script**: Run `./setup-new-project.sh` - this automatically updates all necessary files including the VS Code debug configuration
2. **Manual setup** (if not using the script):
   - Update `launch.json`: Change the hardcoded path in the "Debug Standalone App" configuration
   - Current: `JuceTemplate_artefacts/Debug/Standalone/Juce Template.app/Contents/MacOS/Juce Template`
   - Replace `JuceTemplate` with your CMake target name (from `project()` in CMakeLists.txt)
   - Replace `Juce Template` with your product name (from `PRODUCT_NAME` in src/CMakeLists.txt)
   - Example: `MyPlugin_artefacts/Debug/Standalone/My Plugin.app/Contents/MacOS/My Plugin`
3. **Unit Tests configuration** should work without any changes

## Note about IntelliSense Paths

The `c_cpp_properties.json` includes two JUCE module paths for maximum compatibility:

1. `${workspaceFolder}/JUCE/modules/**` - Used by our default CMake configuration
2. `${workspaceFolder}/build/_deps/juce-src/modules/**` - Standard CPM location

**Why both paths?**

- Our template forces JUCE into `./JUCE/` using `SOURCE_DIR` in CMakeLists.txt
- If someone modifies the CMake setup to use standard CPM, JUCE would go to `build/_deps/juce-src/`
- Having both paths ensures IntelliSense works regardless of the CMake configuration

The second path will show a "Cannot find" warning with our default setup - **this is normal and harmless**. The warning disappears if you switch to standard CPM (by removing the `SOURCE_DIR` line in CMakeLists.txt).

## Getting Started

1. **Build the project** to download JUCE: `./build.sh`
2. **IntelliSense should work** after the first build
3. **Debug configurations** will be available via `F5`
