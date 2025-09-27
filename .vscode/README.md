# VS Code Configuration

This directory contains VS Code-specific configuration files for the JUCE CMake template with complete build and debug integration.

## 🎯 Choose Your Workflow

### 🔰 **For CMake Beginners: Use Build Scripts**

If you're new to CMake or prefer simplicity:

- Use the **build scripts** (`./build.sh`, `./build-tests.sh`)
- Use **Tasks** (Press `⇧⌘B` or Command Palette → "Tasks: Run Task")
- Everything works immediately without configuration

### ⚡ **For CMake Users: Use CMake Tools**

If you're comfortable with CMake and want professional integration:

- Use **CMake Tools status bar buttons** (bottom of VS Code)
- Configure presets, select targets, and build directly
- **Important**: Targets only appear after first build/configure

## Files

- **`c_cpp_properties.json`** - C++ IntelliSense configuration with JUCE plugin macros
- **`launch.json`** - Debug configurations for standalone app and unit tests
- **`tasks.json`** - Build, clean, test, and development tasks
- **`settings.json`** - Workspace settings for optimal task handling

## 🚀 Build and Debug Workflow

### Quick Build

- **Keyboard**: Press `⇧⌘B` (Shift+Cmd+B) - runs default build task
- **Result**: Builds Release version with all plugin formats

### All Build Tasks (Command Palette)

1. **Press `⇧⌘P`** (Shift+Cmd+P)
2. **Type**: "Tasks: Run Task"
3. **Select from**:
   - **Build Project** - Standard Release build
   - **Build Project (Debug)** - Debug build with symbols
   - **Build Tests** - Build unit tests only
   - **Run Tests** - Build and execute unit tests
   - **Clean Build** - Remove all build artifacts
   - **Clean & Rebuild** - Clean then rebuild everything
   - **Setup New Project** - Configure for new project

### Alternative Task Access

- **Terminal Menu**: Terminal → Run Task...
- **Status Bar**: Various CMake Tools buttons (bottom of screen)

## 🐛 Debug Configurations

### Debug Standalone App

- **Access**: Left sidebar "Run and Debug" → "Debug Standalone App" → ▶️
- **Purpose**: Debug the plugin as a standalone application
- **Features**: Full breakpoint debugging, variable inspection
- **Auto-build**: Automatically builds Debug version before launching

### Run Standalone App  

- **Access**: Left sidebar "Run and Debug" → "Run Standalone App" → ▶️
- **Purpose**: Run plugin without debugger (faster startup)
- **Auto-build**: Automatically builds Release version before launching

### Debug Unit Tests

- **Access**: Left sidebar "Run and Debug" → "Debug Unit Tests" → ▶️
- **Purpose**: Debug your unit tests with breakpoints
- **Auto-build**: Automatically builds tests before running

### Attach to Process

- **Access**: Left sidebar "Run and Debug" → "Attach to Process" → ▶️
- **Purpose**: Attach debugger to running DAW or application
- **Use case**: Debug plugin loaded in external host

## ⚡ CMake Tools Workflow

### First-Time Setup (Important!)

**CMake Tools requires an initial build to discover targets:**

1. **Open project** → CMake Tools loads but shows no targets yet
2. **First build** → Use any build method (build script, task, or CMake Tools configure)
3. **Targets appear** → Now CMake Tools status bar shows available targets

### Status Bar Buttons (Bottom of VS Code)

After initial build, you'll see:

- **🔧 Configure** - Configure CMake project
- **🏗️ Build** - Build selected target  
- **🎯 Target** - Select build target (AU, VST3, Standalone, Tests)
- **▶️ Launch** - Run/debug selected target
- **🧹 Clean** - Clean build (keyboard: `⌘⇧K`)

### Build Types & Presets

**Configure Presets** (Build Types):

- 🚀 **Release Build** - Optimized for distribution
- 🐛 **Debug Build** - With debug symbols for development

**Build Presets**:

- 🎵 **Build All Plugins** - All formats (AU, VST3, Standalone)
- 🔧 **Build All (Debug)** - Debug versions of all formats

### Target Selection

Available targets after build:

- **JuceTemplate_AU** - Audio Unit plugin (macOS)
- **JuceTemplate_VST3** - VST3 plugin (cross-platform)
- **JuceTemplate_Standalone** - Standalone application
- **UnitTests** - Test suite

## Project Setup for New Projects

When copying this template to create a new project:

1. **Use the setup script**: Run `./setup-new-project.sh` - this automatically updates all necessary files including VS Code debug configurations, project names, and class names
2. **Manual setup** (if not using the script):
   - Update `launch.json`: Replace `YOURPROJECTNAME` placeholders in debug configurations
   - Find and replace all instances of `YOURPROJECTNAME` with your CMake target name
   - Target name comes from `juce_add_plugin(YourName` in src/CMakeLists.txt
   - Example: If you use `juce_add_plugin(MyPlugin`, replace `YOURPROJECTNAME` with `MyPlugin`
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

## 🎯 Daily Development Workflow

### First-Time Setup

1. **Initial build**: Press `⇧⌘B` or run `./build.sh`
2. **IntelliSense**: Should work automatically after first build
3. **Test everything**: Press `⇧⌘P` → "Tasks: Run Task" → "Run Tests"

### Daily Development

1. **Build**: Press `⇧⌘B` (quick and easy)
2. **Debug**: Left sidebar → "Run and Debug" → select config → ▶️
3. **Clean build**: Press `⇧⌘P` → "Tasks: Run Task" → "Clean & Rebuild"
4. **Run tests**: Press `⇧⌘P` → "Tasks: Run Task" → "Run Tests"

### Alternative Access Methods

- **No F5 needed**: Use left sidebar "Run and Debug" panel with mouse
- **Command Palette**: `⇧⌘P` → "Debug: Start Debugging"
- **Menu Bar**: Run → Start Debugging

### Pro Tips

- **Quick task access**: `⇧⌘P` → type "task" → Enter → select
- **Build failures**: Check Problems panel for detailed error information
- **IntelliSense issues**: Restart VS Code or run "C/C++: Rescan Workspace"

## 🧪 Testing Integration

### Unit Test Framework

- **Framework**: JUCE's built-in UnitTest system
- **Location**: All test files in `tests/` directory
- **Examples**: PluginProcessor tests, PluginEditor tests included

### Running Tests

- **Command line**: `./build-tests.sh`
- **VS Code task**: "Run Tests" via Command Palette
- **Debug tests**: "Debug Unit Tests" configuration

### Writing Tests

1. Create new test class inheriting from `juce::UnitTest`
2. Implement `runTest()` method with test logic
3. Use `expect()`, `expectEquals()`, `beginTest()` macros
4. Create static instance to auto-register test
