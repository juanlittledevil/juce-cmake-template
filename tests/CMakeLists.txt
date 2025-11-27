# Test build configuration

# Find required packages
find_package(PkgConfig REQUIRED)

# Create test executable
add_executable(UnitTests
    TestMain.cpp
    PluginTests.cpp
    # Include plugin source files for testing
    ${CMAKE_SOURCE_DIR}/src/PluginProcessor.cpp
    ${CMAKE_SOURCE_DIR}/src/PluginEditor.cpp
)

# Include directories
target_include_directories(UnitTests
    PRIVATE
        ${CMAKE_SOURCE_DIR}/include
        ${CMAKE_SOURCE_DIR}/src
        ${CMAKE_SOURCE_DIR}/lib
)

# Link libraries
target_link_libraries(UnitTests
    PRIVATE
        juce::juce_audio_utils
        juce::juce_audio_processors
        juce::juce_recommended_config_flags
        juce::juce_recommended_lto_flags
        juce::juce_recommended_warning_flags
)

# Set compile definitions
target_compile_definitions(UnitTests
    PRIVATE
        JUCE_WEB_BROWSER=0
        JUCE_USE_CURL=0
        JUCE_VST3_CAN_REPLACE_VST2=0
        JUCE_UNIT_TESTS=1
        # Plugin definitions needed for testing
        JucePlugin_Name="JuceTemplate"
        JucePlugin_Desc="JuceTemplate"
        JucePlugin_Manufacturer="YourCompany"
        JucePlugin_ManufacturerWebsite=""
        JucePlugin_ManufacturerEmail=""
        JucePlugin_ManufacturerCode=0x4a756365
        JucePlugin_PluginCode=0x4a756365
        JucePlugin_IsSynth=0
        JucePlugin_WantsMidiInput=0
        JucePlugin_ProducesMidiOutput=0
        JucePlugin_IsMidiEffect=0
        JucePlugin_EditorRequiresKeyboardFocus=0
        JucePlugin_Version=1.0.0
        JucePlugin_VersionCode=0x10000
        JucePlugin_VersionString="1.0.0"
        JucePlugin_VSTUniqueID=JucePlugin_PluginCode
        JucePlugin_VSTCategory=kVstEffectType
        JucePlugin_Vst3Category="Fx"
        JucePlugin_AUMainType="'aufx'"
        JucePlugin_AUSubType=JucePlugin_PluginCode
        JucePlugin_AUExportPrefix=JuceTemplateAU
        JucePlugin_AUExportPrefixQuoted="JuceTemplateAU"
        JucePlugin_AUManufacturerCode=JucePlugin_ManufacturerCode
        JucePlugin_CFBundleIdentifier=com.yourcompany.JuceTemplate
        JucePlugin_RTASCategory=2048
        JucePlugin_RTASManufacturerCode=JucePlugin_ManufacturerCode
        JucePlugin_RTASProductId=JucePlugin_PluginCode
        JucePlugin_AAXIdentifier=com.yourcompany.JuceTemplate
        JucePlugin_AAXManufacturerCode=JucePlugin_ManufacturerCode
        JucePlugin_AAXProductId=JucePlugin_PluginCode
        JucePlugin_AAXCategory=2048
        JucePlugin_AAXDisableBypass=0
        JucePlugin_AAXDisableMultiMono=0
        JucePlugin_IAAType=0x61757278
        JucePlugin_IAASubType=JucePlugin_PluginCode
        JucePlugin_IAAName="YourCompany: JuceTemplate"
        JucePlugin_VSTNumMidiInputs=16
        JucePlugin_VSTNumMidiOutputs=16
        JucePlugin_MaxNumInputChannels=64
        JucePlugin_MaxNumOutputChannels=64
        JucePlugin_PreferredChannelConfigurations="{1,1},{2,2}"
)

# Set C++ standard
set_target_properties(UnitTests PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED ON
)

# Enable testing
enable_testing()

# Add test
add_test(
    NAME RunUnitTests
    COMMAND UnitTests
)

if(ENFORCE_OUR_WARNINGS)
    message(STATUS "Enforcing warnings-as-errors for test targets")
    target_compile_options(UnitTests PRIVATE ${OUR_WARNING_FLAGS})
endif()