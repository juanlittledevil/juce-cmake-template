cmake_minimum_required(VERSION 3.24)

# Set the project name and version
project(JuceTemplate VERSION 1.0.0)

# Set C++ standard
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Include CPM (C++ Package Manager)
include(cmake/CPM.cmake)

# Add JUCE as a dependency using CPM
CPMAddPackage(
    NAME JUCE
    GITHUB_REPOSITORY juce-framework/JUCE
    GIT_TAG 8.0.4
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/JUCE
)

# Add subdirectories
add_subdirectory(Source)