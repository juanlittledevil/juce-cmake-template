#pragma once

#include <juce_audio_processors/juce_audio_processors.h>
#include <juce_gui_basics/juce_gui_basics.h>
#include "PluginProcessor.h"

//==============================================================================
/**
*/
class JuceTemplateAudioProcessorEditor  : public juce::AudioProcessorEditor
{
public:
    JuceTemplateAudioProcessorEditor (JuceTemplateAudioProcessor&);
    ~JuceTemplateAudioProcessorEditor() override;

    //==============================================================================
    void paint (juce::Graphics&) override;
    void resized() override;

private:
    // This reference is provided as a quick way for your editor to
    // access the processor object that created it.
    JuceTemplateAudioProcessor& audioProcessor;

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (JuceTemplateAudioProcessorEditor)
};