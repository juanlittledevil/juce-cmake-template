#include "../include/PluginProcessor.h"
#include "../include/PluginEditor.h"

//==============================================================================
JuceTemplateAudioProcessorEditor::JuceTemplateAudioProcessorEditor (JuceTemplateAudioProcessor& p)
    : AudioProcessorEditor (&p), audioProcessor (p)
{
    // Make sure that before the constructor has finished, you've set the
    // editor's size to whatever you need it to be.
    setSize (400, 300);
}

JuceTemplateAudioProcessorEditor::~JuceTemplateAudioProcessorEditor()
{
}

//==============================================================================
void JuceTemplateAudioProcessorEditor::paint (juce::Graphics& g)
{
    // (Our component is opaque, so we must completely fill the background with a solid colour)
    g.fillAll (getLookAndFeel().findColour (juce::ResizableWindow::backgroundColourId));

    g.setColour (juce::Colours::white);
    g.setFont (15.0f);
    g.drawFittedText ("Hello JUCE World!", getLocalBounds(), juce::Justification::centred, 1);
}

void JuceTemplateAudioProcessorEditor::resized()
{
    // This is generally where you'll want to lay out the positions of any
    // subcomponents in your editor..
}