# Source directory CMakeLists.txt

# Create the plugin target
juce_add_plugin(JuceTemplate
    # VERSION ...                               # Set this if the plugin version is different to the project version
    # ICON_BIG ...                              # ICON_* arguments specify a path to an image file to use as an icon for the Standalone
    # ICON_SMALL ...
    COMPANY_NAME "YourCompany"
    BUNDLE_ID "com.yourcompany.jucetemplate"
    IS_SYNTH TRUE                               # Is this a synth or an effect?
    NEEDS_MIDI_INPUT TRUE                       # Does the plugin need midi input?
    NEEDS_MIDI_OUTPUT FALSE                     # Does the plugin need midi output?
    IS_MIDI_EFFECT FALSE                        # Is this plugin a MIDI effect?
    EDITOR_WANTS_KEYBOARD_FOCUS FALSE           # Does the editor need keyboard focus?
    COPY_PLUGIN_AFTER_BUILD TRUE                # Should the plugin be installed to a default location after building?
    PLUGIN_MANUFACTURER_CODE Juce              # A four-character manufacturer id with at least one upper-case character
    PLUGIN_CODE Dem0                            # A unique four-character plugin id with exactly one upper-case character
                                                # GarageBand 10.3 requires the first letter to be upper-case, and the remaining letters to be lower-case
    FORMATS AU VST3 Standalone                  # The formats to build. Other valid formats are: AAX Unity VST AU AUv3
    PRODUCT_NAME "Juce Template")               # The name of the final executable, which can differ from the target name

# Include directories
target_include_directories(JuceTemplate
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/../include
        ${CMAKE_CURRENT_SOURCE_DIR}/../lib)

# Add source files
target_sources(JuceTemplate
    PRIVATE
        PluginEditor.cpp
        PluginProcessor.cpp)

# Add compile definitions
target_compile_definitions(JuceTemplate
    PUBLIC
        # JUCE_WEB_BROWSER and JUCE_USE_CURL would be on by default, but you might not need them.
        JUCE_WEB_BROWSER=0  # If you remove this, add `NEEDS_WEB_BROWSER TRUE` to the `juce_add_plugin` call
        JUCE_USE_CURL=0     # If you remove this, add `NEEDS_CURL TRUE` to the `juce_add_plugin` call
        JUCE_VST3_CAN_REPLACE_VST2=0)

# Link to JUCE libraries
target_link_libraries(JuceTemplate
    PRIVATE
        # AudioPluginData           # If we'd created a binary data target, we'd link to it here
        juce::juce_audio_utils
    PUBLIC
        juce::juce_recommended_config_flags
        juce::juce_recommended_lto_flags
        juce::juce_recommended_warning_flags)

if(ENFORCE_OUR_WARNINGS)
    message(STATUS "Enforcing warnings-as-errors for project targets")
    target_compile_options(JuceTemplate PRIVATE ${OUR_WARNING_FLAGS})
endif()

# Add external libraries support
# Include any external libraries from the lib/ directory
file(GLOB_RECURSE EXTERNAL_LIBS "${CMAKE_CURRENT_SOURCE_DIR}/../lib/*.cpp")
if(EXTERNAL_LIBS)
    target_sources(JuceTemplate PRIVATE ${EXTERNAL_LIBS})
    message(STATUS "Added external libraries: ${EXTERNAL_LIBS}")
endif()