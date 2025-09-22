# Assets Directory

This directory is for storing plugin assets like images, fonts, and audio files.

## Structure

```text
assets/
├── images/          # PNG, JPG, SVG files for UI
├── fonts/           # Custom font files
├── audio/           # Sample audio files, impulse responses
└── data/            # JSON configs, presets, etc.
```

## Usage

Assets can be embedded into your plugin using JUCE's BinaryData system.

### Adding to CMake

Add this to your `Source/CMakeLists.txt`:

```cmake
# Create binary data from assets
juce_add_binary_data(AudioPluginData
    SOURCES
        ../assets/images/logo.png
        ../assets/audio/impulse.wav
        ../assets/data/presets.json)

# Link the binary data
target_link_libraries(YourPlugin PRIVATE AudioPluginData)
```

### Using in Code

```cpp
#include "BinaryData.h"

// Access embedded files
const void* logoData = BinaryData::logo_png;
int logoSize = BinaryData::logo_pngSize;
```

## File Organization

- **images/**: UI graphics, logos, backgrounds
- **fonts/**: Custom typefaces for the interface  
- **audio/**: Impulse responses, samples, demo audio
- **data/**: Configuration files, factory presets