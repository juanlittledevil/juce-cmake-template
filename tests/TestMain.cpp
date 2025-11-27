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

    // parse simple command-line options supported by the template runner
    juce::String category;
    juce::String filter;
    for (int i = 1; i < argc; ++i)
    {
        juce::String arg (argv[i]);
        if (arg.startsWith ("--category="))
            category = arg.fromFirstOccurrenceOf ("=", false, false);
        else if (arg == "--category" && i + 1 < argc)
            category = juce::String (argv[++i]);
        else if (arg.startsWith ("--filter="))
            filter = arg.fromFirstOccurrenceOf ("=", false, false);
        else if (arg == "--filter" && i + 1 < argc)
            filter = juce::String (argv[++i]);
    }

    // Prefer category selection if provided (JUCE has a runTestsInCategory method).
    if (category.isNotEmpty())
    {
        testRunner.runTestsInCategory (category, 0);
    }
    else if (filter.isNotEmpty())
    {
        // FILTER PLUMBING
        // ----------------
        // We parse a --filter argument here and expose a single, well-known
        // place where consumers can hook filtering behaviour later. At the
        // moment the template doesn't implement a deep integration with the
        // JUCE UnitTest internals; implementing full name-based filtering will
        // require calling the appropriate UnitTestRunner API or iterating
        // the registered tests and selectively executing them.
        //
        // For now: acknowledge and surface the filter so the variable is used
        // and contributors have a clear integration point to implement.
        std::cout << "Filter provided: '" << filter << "' — running filtered tests (plumbing only)\n";

        // TODO: When integrating a name-based test filter, replace the
        // following call with runner API that runs tests matching `filter`.
        testRunner.runAllTests (0);
    }
    else
    {
        testRunner.runAllTests (0);
    }
    
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