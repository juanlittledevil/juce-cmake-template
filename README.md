# JUCE CMake Template

A modern JUCE audio plugin template using CMake and CPM (C++ Package Manager) for dependency management. This template avoids Xcode project files and uses CMake tools exclusively.

## Features

- Modern CMake setup (3.24+)
- Uses CPM for automatic JUCE dependency management
- No Xcode project files required (uses CMake tools only)
- Supports VST3, AU, and Standalone formats
- C++20 standard
- Automatic plugin installation to system directories
- Cross-platform build system

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

#### 2. Plugin Configuration (`Source/CMakeLists.txt`)
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
- `Source/PluginProcessor.h` - Class declarations
- `Source/PluginProcessor.cpp` - Class implementations  
- `Source/PluginEditor.h` - Editor class declaration
- `Source/PluginEditor.cpp` - Editor implementation

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

### Build and Run

1. **Quick Build** (recommended):

```bash
./build.sh
```

2. **Manual Build**:

```bash
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build . --config Release
```

3. **Run the Standalone App**:

```bash
open "./build/Source/JuceTemplate_artefacts/Release/Standalone/Juce Template.app"
```

### Clean Build

To clean all build artifacts:

```bash
./clean.sh
```

## Project Structure

```text
├── CMakeLists.txt             # Main CMake configuration
├── build.sh                  # Quick build script  
├── clean.sh                  # Clean build script
├── setup-new-project.sh      # New project setup script
├── cmake/
│   └── CPM.cmake             # CPM package manager
├── Source/
│   ├── CMakeLists.txt        # Source-specific CMake config
│   ├── PluginProcessor.h/.cpp
│   └── PluginEditor.h/.cpp
└── README.md
```

## Configuration

Edit the `Source/CMakeLists.txt` file to customize:

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

1. Customize the plugin parameters in `PluginProcessor.cpp`
2. Design your UI in `PluginEditor.cpp`
3. Add DSP processing in the `processBlock()` method
4. Configure plugin properties in `Source/CMakeLists.txt`

Happy coding! 🎵
