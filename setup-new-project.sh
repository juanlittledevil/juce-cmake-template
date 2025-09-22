#!/bin/bash

# JUCE CMake Template - New Project Setup Script
# This script helps you quickly set up a new JUCE project from this template

set -e

echo "🎵 JUCE CMake Template - New Project Setup"
echo "=========================================="
echo

# Function to prompt for user input with default value
prompt_with_default() {
    local prompt="$1"
    local default="$2"
    local varname="$3"
    
    read -p "$prompt [$default]: " input
    if [ -z "$input" ]; then
        eval "$varname='$default'"
    else
        eval "$varname='$input'"
    fi
}

# Get project details from user
echo "📝 Let's set up your new JUCE project!"
echo

prompt_with_default "Project name (used for target names)" "MyPlugin" PROJECT_NAME
prompt_with_default "Product name (displayed to users)" "My Plugin" PRODUCT_NAME
prompt_with_default "Company name" "MyCompany" COMPANY_NAME
prompt_with_default "Company domain (for bundle ID)" "mycompany.com" COMPANY_DOMAIN
prompt_with_default "Plugin type (synth/effect)" "effect" PLUGIN_TYPE
prompt_with_default "Needs MIDI input? (yes/no)" "no" NEEDS_MIDI

echo
echo "🔧 Configuration Summary:"
echo "   Project Name: $PROJECT_NAME"
echo "   Product Name: $PRODUCT_NAME"
echo "   Company: $COMPANY_NAME"
echo "   Domain: $COMPANY_DOMAIN"
echo "   Type: $PLUGIN_TYPE"
echo "   MIDI Input: $NEEDS_MIDI"
echo

read -p "Continue with this configuration? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Setup cancelled"
    exit 1
fi

# Convert inputs to CMake values
if [ "$PLUGIN_TYPE" = "synth" ]; then
    IS_SYNTH="TRUE"
else
    IS_SYNTH="FALSE"
fi

if [ "$NEEDS_MIDI" = "yes" ] || [ "$NEEDS_MIDI" = "y" ]; then
    MIDI_INPUT="TRUE"
else
    MIDI_INPUT="FALSE"
fi

# Generate bundle ID (remove spaces and convert to lowercase)
CLEAN_COMPANY=$(echo "$COMPANY_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/ //g')
CLEAN_PROJECT=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/ //g')
BUNDLE_ID="com.${CLEAN_COMPANY}.${CLEAN_PROJECT}"

# Generate 4-character codes
MANUFACTURER_CODE=$(echo "$COMPANY_NAME" | tr '[:lower:]' '[:upper:]' | sed 's/[^A-Z]//g' | cut -c1-4 | head -c4)
# Pad with 'X' if too short
while [ ${#MANUFACTURER_CODE} -lt 4 ]; do
    MANUFACTURER_CODE="${MANUFACTURER_CODE}X"
done

PROJECT_CODE=$(echo "$PROJECT_NAME" | sed 's/[^A-Za-z0-9]//g' | cut -c1-3)
PROJECT_CODE=$(echo "$PROJECT_CODE" | tr '[:lower:]' '[:upper:]')$(echo "0")
# Ensure first char is uppercase, rest lowercase, exactly 4 chars
PROJECT_CODE=$(echo "$PROJECT_CODE" | cut -c1)$(echo "$PROJECT_CODE" | cut -c2-4 | tr '[:upper:]' '[:lower:]')

echo
echo "🚀 Updating project files..."

# Update CMakeLists.txt - main project name
sed -i '' "s/project(JuceTemplate VERSION 1.0.0)/project($PROJECT_NAME VERSION 1.0.0)/" CMakeLists.txt

# Update Source/CMakeLists.txt with all the new values
cat > Source/CMakeLists.txt << EOF
# Source directory CMakeLists.txt

# Create the plugin target
juce_add_plugin($PROJECT_NAME
    # VERSION ...                               # Set this if the plugin version is different to the project version
    # ICON_BIG ...                              # ICON_* arguments specify a path to an image file to use as an icon for the Standalone
    # ICON_SMALL ...
    COMPANY_NAME "$COMPANY_NAME"
    BUNDLE_ID "$BUNDLE_ID"
    IS_SYNTH $IS_SYNTH                          # Is this a synth or an effect?
    NEEDS_MIDI_INPUT $MIDI_INPUT                # Does the plugin need midi input?
    NEEDS_MIDI_OUTPUT FALSE                     # Does the plugin need midi output?
    IS_MIDI_EFFECT FALSE                        # Is this plugin a MIDI effect?
    EDITOR_WANTS_KEYBOARD_FOCUS FALSE           # Does the editor need keyboard focus?
    COPY_PLUGIN_AFTER_BUILD TRUE                # Should the plugin be installed to a default location after building?
    PLUGIN_MANUFACTURER_CODE $MANUFACTURER_CODE # A four-character manufacturer id with at least one upper-case character
    PLUGIN_CODE $PROJECT_CODE                   # A unique four-character plugin id with exactly one upper-case character
                                                # GarageBand 10.3 requires the first letter to be upper-case, and the remaining letters to be lower-case
    FORMATS AU VST3 Standalone                  # The formats to build. Other valid formats are: AAX Unity VST AU AUv3
    PRODUCT_NAME "$PRODUCT_NAME")               # The name of the final executable, which can differ from the target name

# Add source files
target_sources($PROJECT_NAME
    PRIVATE
        PluginEditor.cpp
        PluginProcessor.cpp)

# Add compile definitions
target_compile_definitions($PROJECT_NAME
    PUBLIC
        # JUCE_WEB_BROWSER and JUCE_USE_CURL would be on by default, but you might not need them.
        JUCE_WEB_BROWSER=0  # If you remove this, add \`NEEDS_WEB_BROWSER TRUE\` to the \`juce_add_plugin\` call
        JUCE_USE_CURL=0     # If you remove this, add \`NEEDS_CURL TRUE\` to the \`juce_add_plugin\` call
        JUCE_VST3_CAN_REPLACE_VST2=0)

# Link to JUCE libraries
target_link_libraries($PROJECT_NAME
    PRIVATE
        # AudioPluginData           # If we'd created a binary data target, we'd link to it here
        juce::juce_audio_utils
    PUBLIC
        juce::juce_recommended_config_flags
        juce::juce_recommended_lto_flags
        juce::juce_recommended_warning_flags)
EOF

# Update class names in header files
OLD_CLASS_NAME="JuceTemplateAudioProcessor"
NEW_CLASS_NAME="${PROJECT_NAME}AudioProcessor"

# Update PluginProcessor.h
sed -i '' "s/$OLD_CLASS_NAME/$NEW_CLASS_NAME/g" Source/PluginProcessor.h

# Update PluginProcessor.cpp  
sed -i '' "s/$OLD_CLASS_NAME/$NEW_CLASS_NAME/g" Source/PluginProcessor.cpp

# Update PluginEditor.h
OLD_EDITOR_CLASS="JuceTemplateAudioProcessorEditor"
NEW_EDITOR_CLASS="${PROJECT_NAME}AudioProcessorEditor"
sed -i '' "s/$OLD_EDITOR_CLASS/$NEW_EDITOR_CLASS/g" Source/PluginEditor.h
sed -i '' "s/$OLD_CLASS_NAME/$NEW_CLASS_NAME/g" Source/PluginEditor.h

# Update PluginEditor.cpp
sed -i '' "s/$OLD_EDITOR_CLASS/$NEW_EDITOR_CLASS/g" Source/PluginEditor.cpp
sed -i '' "s/$OLD_CLASS_NAME/$NEW_CLASS_NAME/g" Source/PluginEditor.cpp

# Update the Hello World message
sed -i '' "s/Hello JUCE World!/Hello $PRODUCT_NAME!/g" Source/PluginEditor.cpp

echo "✅ Project setup complete!"
echo
echo "📊 Summary of changes:"
echo "   • Project name: JuceTemplate → $PROJECT_NAME"
echo "   • Class names: JuceTemplateAudioProcessor → ${NEW_CLASS_NAME}"
echo "   • Bundle ID: $BUNDLE_ID"
echo "   • Manufacturer code: $MANUFACTURER_CODE"
echo "   • Plugin code: $PROJECT_CODE"
echo "   • Welcome message updated"
echo
echo "🏗️  Ready to build your new project:"
echo "   ./build.sh"
echo
echo "🎉 Happy coding!"
EOF