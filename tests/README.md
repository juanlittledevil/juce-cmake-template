# Unit Tests for JUCE Project

This directory contains unit tests for the JUCE project using JUCE's built-in testing framework.

## Running Tests

### From Command Line

```bash
./build-tests.sh    # Build tests
./build/tests/UnitTests  # Run tests
```

### From VS Code

- **Build & Run Tests**: `Cmd+Shift+P` → "Tasks: Run Task" → "Run Tests"
- **Debug Tests**: `F5` → "Debug Unit Tests"
- **Run Tests Only**: `Cmd+Shift+P` → "Tasks: Run Task" → "Build Tests"

## Test Structure

- `CMakeLists.txt` - Test build configuration
- `TestMain.cpp` - Test runner entry point
- `PluginTests.cpp` - Plugin-specific tests
- Add more test files as needed

## Writing Tests

JUCE uses its own testing framework. Here's a basic test structure:

```cpp
class MyUnitTest : public juce::UnitTest
{
public:
    MyUnitTest() : juce::UnitTest("My Test Category") {}
    
    void runTest() override
    {
        beginTest("Test description");
        
        // Your test code here
        expect(someCondition, "Error message if fails");
        expectEquals(actualValue, expectedValue, "Values should match");
    }
};

// Register the test
static MyUnitTest myUnitTest;
```

## Test Categories

- **Audio Processing Tests**: Test DSP algorithms and audio processing
- **Parameter Tests**: Test plugin parameters and automation
- **GUI Tests**: Test UI components and interactions
- **Utility Tests**: Test helper functions and utilities

## Best Practices

1. Keep tests focused and atomic
2. Use descriptive test names
3. Test both success and failure cases
4. Mock external dependencies when possible
5. Use JUCE's expectation macros for clear feedback
