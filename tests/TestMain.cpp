#include <juce_audio_utils/juce_audio_utils.h>

/*
    Test Runner Entry Point
    
    This file sets up and runs all unit tests for the JUCE project.
    JUCE's testing framework automatically discovers and runs all registered tests.
*/

//==============================================================================
int main (int argc, char* argv[])
{
    juce::ScopedJuceInitialiser_GUI libraryInitialiser;
    
    // Create test runner
    juce::UnitTestRunner testRunner;
    
    // Run all tests
    testRunner.runAllTests();
    
    // Print results
    int numFailures = 0;
    for (int i = 0; i < testRunner.getNumResults(); ++i)
    {
        auto result = testRunner.getResult(i);
        numFailures += result->failures;
        
        std::cout << "Test: " << result->unitTestName 
                  << " - " << result->passes << " passed, " 
                  << result->failures << " failed" << std::endl;
    }
    
    if (numFailures > 0)
    {
        std::cout << "\n" << numFailures << " test(s) failed!" << std::endl;
        return 1;
    }
    else
    {
        std::cout << "\nAll tests passed!" << std::endl;
        return 0;
    }
}