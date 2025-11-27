cmake_minimum_required(VERSION 3.24)

# Set the project name and version
project(JuceTemplate VERSION 1.0.0)

# Generate a compile_commands.json by default to help IDEs (VS Code/C/C++ extension)
# Users may override this by setting CMAKE_EXPORT_COMPILE_COMMANDS explicitly when
# configuring (e.g. -DCMAKE_EXPORT_COMPILE_COMMANDS=OFF).
if(NOT DEFINED CMAKE_EXPORT_COMPILE_COMMANDS)
    set(CMAKE_EXPORT_COMPILE_COMMANDS ON CACHE BOOL "Generate compile_commands.json for IDEs")
endif()

# Option: Treat our own warnings as errors (target-scoped) so contributors don't leave cruft.
# This only affects project targets (applied later in src/ and tests/) and does NOT change
# third-party or JUCE-provided targets.
option(ENFORCE_OUR_WARNINGS "Treat warnings as errors for repository source targets" OFF)

if(MSVC)
    set(OUR_WARNING_FLAGS /WX /W4)
else()
    set(OUR_WARNING_FLAGS -Werror -Wall -Wextra -Wpedantic)
endif()

# Set C++ standard
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Include CPM (C++ Package Manager)
include(cmake/CPM.cmake)

# Add JUCE as a dependency using CPM
CPMAddPackage(
    NAME JUCE
    GITHUB_REPOSITORY juce-framework/JUCE
    GIT_TAG 8.0.10
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/JUCE
)

# Add external libraries
add_subdirectory(lib)

# Add source directory
add_subdirectory(src)

# Enable testing and add tests if BUILD_TESTING is ON
include(CTest)
if(BUILD_TESTING)
    add_subdirectory(tests)
endif()