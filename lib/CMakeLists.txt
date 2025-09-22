# External Libraries CMakeLists.txt
# Add your external library dependencies here using CPM

# Example: Adding a popular DSP library
# CPMAddPackage(
#     NAME AudioFFT
#     GITHUB_REPOSITORY HiFi-LoFi/AudioFFT
#     GIT_TAG master
# )

# Example: Adding a JSON library
# CPMAddPackage(
#     NAME nlohmann_json
#     GITHUB_REPOSITORY nlohmann/json
#     VERSION 3.11.3
# )

# Example: Adding eigen for linear algebra
# CPMAddPackage(
#     NAME Eigen3
#     GITHUB_REPOSITORY eigenteam/eigen-git-mirror
#     GIT_TAG 3.4.0
# )

# Example: Adding a GUI library
# CPMAddPackage(
#     NAME ImGui
#     GITHUB_REPOSITORY ocornut/imgui
#     GIT_TAG v1.90.0
# )

# Add any custom library configurations here
message(STATUS "External libraries configuration loaded")