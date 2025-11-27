#include <juce_audio_utils/juce_audio_utils.h>
#include "../include/PluginProcessor.h"

/*
    Plugin Unit Tests
    
    This file contains unit tests specifically for the plugin functionality.
    Add more test classes here as your plugin grows in complexity.
*/

//==============================================================================
class PluginBasicTests : public juce::UnitTest
{
public:
    PluginBasicTests() : juce::UnitTest("Plugin Basic Tests", "project") {}
    
    void runTest() override
    {
        beginTest("Plugin instantiation");
        
        // Test that we can create a plugin instance
        auto plugin = std::make_unique<JuceTemplateAudioProcessor>();
        expect(plugin != nullptr, "Plugin should be created successfully");
        
        beginTest("Plugin properties");
        
        // Test basic plugin properties
        expect(plugin->getName().isNotEmpty(), "Plugin should have a name");
        expect(plugin->getTotalNumInputChannels() >= 0, "Input channels should be >= 0");
        expect(plugin->getTotalNumOutputChannels() >= 0, "Output channels should be >= 0");
        
        beginTest("Plugin state");
        
        // Test plugin state (using non-deprecated methods when available)
        expect(plugin->getNumPrograms() >= 1, "Should have at least one program");
        expect(plugin->getCurrentProgram() >= 0, "Current program should be valid");
        
        // Test parameter tree if available
        auto paramTree = plugin->getParameters();
        expect(paramTree.size() >= 0, "Should have valid parameter tree");
        
        beginTest("Sample rate handling");
        
        // Test sample rate preparation
        double sampleRate = 44100.0;
        int blockSize = 512;
        
        plugin->prepareToPlay(sampleRate, blockSize);
        expectWithinAbsoluteError(plugin->getSampleRate(), sampleRate, 0.1, "Sample rate should be set correctly");
        
        plugin->releaseResources();
    }
};

//==============================================================================
class PluginProcessingTests : public juce::UnitTest
{
public:
    PluginProcessingTests() : juce::UnitTest("Plugin Processing Tests", "project") {}
    
    void runTest() override
    {
        beginTest("Audio processing basic test");
        
        auto plugin = std::make_unique<JuceTemplateAudioProcessor>();
        
        // Set up processing
        double sampleRate = 44100.0;
        int blockSize = 512;
        int numChannels = 2;
        
        plugin->prepareToPlay(sampleRate, blockSize);
        
        // Create test audio buffer
        juce::AudioBuffer<float> buffer(numChannels, blockSize);
        
        // Fill with test signal (sine wave)
        for (int channel = 0; channel < numChannels; ++channel)
        {
            auto* channelData = buffer.getWritePointer(channel);
            for (int sample = 0; sample < blockSize; ++sample)
            {
                channelData[sample] = std::sin(2.0 * juce::MathConstants<double>::pi * 440.0 * sample / sampleRate);
            }
        }
        
        // Create MIDI buffer (empty for this test)
        juce::MidiBuffer midiBuffer;
        
        // Process the audio
        plugin->processBlock(buffer, midiBuffer);
        
        // Check that processing didn't crash and buffer is still valid
        expect(buffer.getNumChannels() == numChannels, "Channel count should remain unchanged");
        expect(buffer.getNumSamples() == blockSize, "Sample count should remain unchanged");
        
        // Check that output contains some signal (not just silence)
        bool hasSignal = false;
        for (int channel = 0; channel < numChannels; ++channel)
        {
            auto* channelData = buffer.getReadPointer(channel);
            for (int sample = 0; sample < blockSize; ++sample)
            {
                if (std::abs(channelData[sample]) > 0.001f)
                {
                    hasSignal = true;
                    break;
                }
            }
        }
        
        expect(hasSignal, "Plugin should process audio (not just silence)");
        
        plugin->releaseResources();
    }
};

//==============================================================================
class PluginParameterTests : public juce::UnitTest
{
public:
    PluginParameterTests() : juce::UnitTest("Plugin Parameter Tests", "project") {}
    
    void runTest() override
    {
        beginTest("Parameter access");
        
        auto plugin = std::make_unique<JuceTemplateAudioProcessor>();
        
        // Test parameter tree access (modern JUCE approach)
        auto paramTree = plugin->getParameters();
        expect(paramTree.size() >= 0, "Parameter tree should be valid");
        
        beginTest("Program handling");
        
        // Test program switching
        int numPrograms = plugin->getNumPrograms();
        expect(numPrograms >= 1, "Should have at least one program");
        
        int originalProgram = plugin->getCurrentProgram();
        expect(originalProgram >= 0 && originalProgram < numPrograms, "Current program should be valid");
        
        // Test program name
        juce::String programName = plugin->getProgramName(originalProgram);
        expect(programName.isNotEmpty(), "Program should have a name");
    }
};

//==============================================================================
// Register the test classes with JUCE's test framework
static PluginBasicTests pluginBasicTests;
static PluginProcessingTests pluginProcessingTests;
static PluginParameterTests pluginParameterTests;