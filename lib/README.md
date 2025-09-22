# External Libraries

This directory is for managing external dependencies and custom libraries.

## Structure

- **Header-only libraries**: Place `.h` files directly here
- **Source libraries**: Create subdirectories for each library
- **CPM dependencies**: Configure in `CMakeLists.txt`

## Examples

### Adding a Header-Only Library
For simple header-only libraries, just copy the headers here:
```
lib/
├── my-dsp-lib/
│   ├── Reverb.h
│   └── Delay.h
└── CMakeLists.txt
```

### Adding via CPM
For libraries available on GitHub, add to `CMakeLists.txt`:
```cmake
CPMAddPackage(
    NAME MyLibrary
    GITHUB_REPOSITORY user/mylibrary
    GIT_TAG v1.0.0
)
target_link_libraries(YourPlugin PRIVATE MyLibrary)
```

### Common Audio Libraries

- **AudioFFT**: Fast FFT library
- **nlohmann/json**: JSON parsing
- **Eigen**: Linear algebra
- **libsamplerate**: Sample rate conversion
- **FFTW**: Advanced FFT operations

## Usage

Once added here, libraries are automatically available in your plugin code via:
```cpp
#include "my-dsp-lib/Reverb.h"
```