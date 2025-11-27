# JUCE CMake Template

> **⚠️ NOTICE:**
> This template has **ONLY been tested on macOS** as of September 2025. Windows and Linux support is expected, but not yet verified. If you encounter issues on other platforms, please open an issue or contribute fixes!

A modern JUCE audio plugin template using CMake and CPM (C++ Package Manager) for dependency management. This template avoids Xcode project files and uses CMake tools exclusively.

## Features

- Modern CMake setup (3.24+)
- Uses CPM for automatic JUCE dependency management
- No Xcode project files required (uses CMake tools only)
- Supports VST3, AU, and Standalone formats
- C++20 standard
- Automatic plugin installation to system directories
- Cross-platform build system
- Professional project structure with separated headers/implementation
- External library management system
- Asset management for resources (images, audio, fonts)
- Complete testing and debugging support with VS Code integration

## 🧪 Testing & Debugging

This template includes comprehensive testing and debugging support:

### Unit Testing

- **JUCE's built-in test framework** for reliable testing
- **Example tests** for plugin functionality
- **Command line testing**: `./build-tests.sh`
- **VS Code integration**: Run tests via tasks or debug them directly

### Debugging in VS Code

- **Full debugging support** with breakpoints and variable inspection
- **Debug configurations** for standalone app and unit tests
- **Task integration** for building and running
- **IntelliSense** and code completion

### Getting Started with Testing

1. **Build and test**: `./build-tests.sh`
2. **Debug standalone**: Press `F5` → "Debug Standalone App"
3. **Debug tests**: Press `F5` → "Debug Unit Tests"
4. **Add tests**: Create new test classes in `tests/`

📖 **See [DEBUGGING.md](DEBUGGING.md) for detailed testing and debugging guide**

📚 Developer docs: See the top-level docs entry for more detailed guides and a central index:

- `docs/index.md` — canonical entry point for project documentation (developer docs, architecture, testing guidance)


## Using as a Template

This project is designed to be a reusable template for new JUCE projects. Here's how to create a new project:

### 🚀 Quick Project Setup (Automated)

1. **Copy this template folder**:

   ```bash
   cp -r /path/to/JUCE-CMake-Template /path/to/MyNewPlugin
   cd /path/to/MyNewPlugin
   ```

2. **Run the setup script**:

   ```bash
   ./setup-new-project.sh
   ```

  The script will prompt you for:
   - Project name (e.g., "MyReverb")
   - Product name (e.g., "My Reverb Plugin")
   - Company name (e.g., "MyCompany")
   - Company domain (e.g., "mycompany.com")
   - Plugin type (synth or effect)
   - MIDI input requirement

  Additionally, the setup script now includes an option to enable project-wide "warnings-as-errors" enforcement. This is OFF by default (recommended) to avoid third-party or template warnings breaking a first-time build; during setup you'll be asked whether you want to enable it for the new project. You can always change this later in the new project's `CMakeLists.txt` by setting `ENFORCE_OUR_WARNINGS` ON or OFF.

3. **Build your new project**:

   ```bash
   ./build.sh
   ```

### 🛠️ Manual Project Setup

If you prefer to customize manually, here are the files you need to modify:

#### 1. Main Project Configuration (`CMakeLists.txt`)

```cmake
project(YourProjectName VERSION 1.0.0)  # Change project name
```

#### 2. Plugin Configuration (`src/CMakeLists.txt`)

```cmake
juce_add_plugin(YourProjectName
    COMPANY_NAME "Your Company"
    BUNDLE_ID "com.yourcompany.yourproject"
    IS_SYNTH FALSE                    # TRUE for synths, FALSE for effects
    NEEDS_MIDI_INPUT FALSE            # TRUE if plugin needs MIDI
    PLUGIN_MANUFACTURER_CODE YrCo     # 4-char company code
    PLUGIN_CODE YrP1                  # 4-char plugin code (1st uppercase)
    PRODUCT_NAME "Your Plugin Name")
```

#### 3. Class Names (Source Files)

Replace these class names throughout the source files:

- `JuceTemplateAudioProcessor` → `YourProjectAudioProcessor`
- `JuceTemplateAudioProcessorEditor` → `YourProjectAudioProcessorEditor`

#### 4. Files to Update

- `include/PluginProcessor.h` - Processor class declaration
- `src/PluginProcessor.cpp` - Processor implementation  
- `include/PluginEditor.h` - Editor class declaration
- `src/PluginEditor.cpp` - Editor implementation

### 📋 Project Naming Guidelines

- **Project Name**: Used for CMake target (no spaces, PascalCase)
- **Product Name**: User-facing name (can have spaces)
- **Bundle ID**: Reverse domain format (e.g., com.company.plugin)
- **Manufacturer Code**: 4 characters, at least one uppercase
- **Plugin Code**: 4 characters, first uppercase, rest lowercase

### 💡 Template Best Practices

- **Keep the template clean**: Don't modify the template directly for your projects
- **Copy first, then customize**: Always copy the entire folder before running setup
- **Use meaningful names**: Choose descriptive project and class names
- **Update README**: Customize the README.md for your specific project
- **Version control**: Initialize git in your new project folder after setup

## Quick Start

### Prerequisites

- CMake 3.24 or later
- Xcode Command Line Tools (for macOS): `xcode-select --install`
- A C++20 compatible compiler
- VS Code with C/C++ extension (recommended for best experience)

### Build and Run

#### 🎯 VS Code Integration (Recommended)

**Two Workflow Options:**

� **Script Tasks (Beginner-friendly)** - Traditional task-based workflow, works immediately  
⚡ **CMake Tools (Professional)** - Status bar buttons for build/debug

> **Cross-Platform Note**: VS Code configuration auto-detects your platform's compiler and architecture. Works on macOS (Intel/Apple Silicon), Windows, and Linux without modification.

additionally,

> **⚠️ CMake Tools Important**: If using CMake Tools status bar buttons, targets only appear after the first build/configure. For immediate functionality, use Script Tasks instead.

**One-Button Workflow:**

1. **Open in VS Code**: `code .`
2. **Select Kit**: Choose compiler when prompted (CMake Tools only)
3. **Build**: Press `⇧⌘B` (Shift+Cmd+B) or use status bar Build button  
4. **Run**: Left sidebar → "Run and Debug" → "Run Standalone App" → ▶️
5. **Debug**: Left sidebar → "Run and Debug" → "Debug Standalone App" → ▶️

**All Build Tasks:**

- Press `⇧⌘P` → "Tasks: Run Task" → choose:
  - Build Project (Release)
  - Build Project (Debug)  
  - Build Tests
  - Run Tests
  - Clean Build
  - Clean & Rebuild

#### 📋 Command Line

a. **Quick Build** (recommended):

```bash
./build.sh
```

b. **Manual Build**:

```bash
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build . --config Release
```

c. **Run the Standalone App**:

```bash
open "./build/src/JuceTemplate_artefacts/Release/Standalone/Juce Template.app"
```

#### 🧹 Clean Build

**VS Code**: Press `⇧⌘P` → "Tasks: Run Task" → "Clean & Rebuild"

**Command Line**:

```bash
./clean.sh
```

#### 🧪 Testing

**VS Code**: Press `⇧⌘P` → "Tasks: Run Task" → "Run Tests"

**Command Line**:

```bash
./build-tests.sh
```

## Project Structure

```text
├── CMakeLists.txt             # Main CMake configuration
├── build.sh                  # Quick build script  
├── clean.sh                  # Clean build script
├── setup-new-project.sh      # New project setup script
├── cmake/
│   └── CPM.cmake             # CPM package manager
├── include/                   # Header files (.h)
│   ├── PluginProcessor.h     
│   └── PluginEditor.h        
├── src/                      # Implementation files (.cpp) + build config
│   ├── CMakeLists.txt        # Plugin build configuration
│   ├── PluginProcessor.cpp   
│   └── PluginEditor.cpp      
├── lib/                      # External libraries
│   ├── CMakeLists.txt        # Library dependency configuration
│   └── README.md             # Library usage guide
├── assets/                   # Plugin resources
│   ├── images/               # UI graphics, logos
│   ├── fonts/                # Custom fonts
│   ├── audio/                # Samples, impulse responses
│   ├── data/                 # Config files, presets
│   └── README.md             # Asset usage guide
└── README.md
```

## Configuration

Edit the `src/CMakeLists.txt` file to customize:

- **Plugin Identity**:

  ```cmake
  COMPANY_NAME "YourCompany"
  BUNDLE_ID "com.yourcompany.pluginname"
  PRODUCT_NAME "Your Plugin Name"
  ```

- **Plugin Type**:

  ```cmake
  IS_SYNTH TRUE              # TRUE for synthesizers, FALSE for effects
  NEEDS_MIDI_INPUT TRUE      # Does plugin need MIDI input?
  IS_MIDI_EFFECT FALSE       # Is this a MIDI effect?
  ```

- **Plugin Formats**:

  ```cmake
  FORMATS AU VST3 Standalone AAX  # Available: AU, VST3, VST, AAX, AUv3, Unity, LV2
  ```

## Development Tips

### Debug Build

For development with debug symbols:

```bash
mkdir build-debug && cd build-debug
cmake .. -DCMAKE_BUILD_TYPE=Debug
cmake --build . --config Debug
```

### Using Different JUCE Versions

Edit `CMakeLists.txt` and change the GIT_TAG:

```cmake
CPMAddPackage(
    NAME JUCE
    GITHUB_REPOSITORY juce-framework/JUCE
    GIT_TAG 8.0.4  # Change this to desired version
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/JUCE
)
```

### Plugin Installation

Built plugins are automatically installed to:

- **AU**: `~/Library/Audio/Plug-Ins/Components/`
- **VST3**: `~/Library/Audio/Plug-Ins/VST3/`

### Working with External Libraries

Add libraries to `lib/CMakeLists.txt`:

```cmake
CPMAddPackage(
    NAME MyLibrary
    GITHUB_REPOSITORY user/mylibrary
    GIT_TAG v1.0.0
)
target_link_libraries(YourPlugin PRIVATE MyLibrary)
```

### Asset Management

Place assets in the `assets/` directory and add to `src/CMakeLists.txt`:

```cmake
juce_add_binary_data(AudioPluginData
    SOURCES
        ../assets/images/logo.png
        ../assets/audio/impulse.wav)
target_link_libraries(YourPlugin PRIVATE AudioPluginData)
```

## Troubleshooting

### Common Issues

1. **Build fails with "juceaide" errors**: Try using a newer JUCE version
2. **"Bundle ID contains spaces" warning**: Update `BUNDLE_ID` in `Source/CMakeLists.txt`
3. **Missing Xcode tools**: Run `xcode-select --install`

### Getting Help

- Check the [JUCE Documentation](https://docs.juce.com/)
- Visit the [JUCE Forum](https://forum.juce.com/)
- Review [CMake JUCE Guide](https://github.com/juce-framework/JUCE/blob/master/docs/CMake%20API.md)

## What's Different from Projucer?

✅ **Advantages:**

- No Xcode project files to manage
- Easier dependency management with CPM
- Better version control (fewer generated files)
- Cross-platform build system
- Modern C++ standards support

⚠️ **Considerations:**

- Requires understanding of CMake
- Different project structure than Projucer
- Manual configuration instead of GUI

## Next Steps

1. Customize the plugin parameters in `src/PluginProcessor.cpp`
2. Design your UI in `src/PluginEditor.cpp`
3. Add DSP processing in the `processBlock()` method
4. Configure plugin properties in `src/CMakeLists.txt`
5. Add external libraries in `lib/CMakeLists.txt`
6. Include assets (images, audio) in `assets/` directory

Happy coding! 🎵
