# Debugging & Testing Guide

This guide covers debugging and testing your JUCE plugin in VS Code.

## 🛠️ Required Extensions

Install these VS Code extensions (they're in the recommended list):

- **C/C++** (ms-vscode.cpptools) - Core C++ support
- **CMake Tools** (ms-vscode.cmake-tools) - CMake integration
- **C/C++ Extension Pack** (ms-vscode.cpptools-extension-pack) - Additional tools

## 🐛 Debugging

### Debug Standalone Application

1. **Build the project**: `Cmd+Shift+P` → "Tasks: Run Task" → "Build Project"
2. **Set breakpoints** in your source files
3. **Start debugging**: `F5` → "Debug Standalone App"

The debugger will:

- Build the project automatically
- Launch the standalone app
- Attach the debugger
- Stop at your breakpoints

### Debug Plugin in DAW

Since debugging plugins in DAWs can be complex, here are two approaches:

#### Option 1: Attach to DAW Process

1. Open your DAW (Logic, Ableton, etc.)
2. Load your plugin
3. In VS Code: `F5` → "Attach to Process"
4. Select your DAW process from the list
5. Set breakpoints and trigger plugin code

#### Option 2: Debug Standalone and Test Plugin Logic

1. Move plugin logic to testable functions
2. Create unit tests for the logic
3. Debug the standalone app which uses the same code

### Debug Unit Tests

1. **Set breakpoints** in test files or plugin code
2. **Start debugging**: `F5` → "Debug Unit Tests"
3. The debugger will build and run tests, stopping at breakpoints

## 🧪 Testing

### Running Tests

#### From Command Line

```bash
./build-tests.sh    # Build and run all tests
./build/tests/UnitTests  # Run tests directly
```

#### From VS Code

- **Build & Run**: `Cmd+Shift+P` → "Tasks: Run Task" → "Run Tests"
- **Build Only**: `Cmd+Shift+P` → "Tasks: Run Task" → "Build Tests"
- **Debug Tests**: `F5` → "Debug Unit Tests"

### Writing Tests

JUCE includes a built-in testing framework. Here's how to add tests:

#### 1. Create a Test Class

```cpp
#include <JuceHeader.h>

class MyFeatureTest : public juce::UnitTest
{
public:
    MyFeatureTest() : juce::UnitTest("My Feature Tests") {}
    
    void runTest() override
    {
        beginTest("Test description");
        
        // Test your code
        int result = myFunction(42);
        expectEquals(result, 84, "Function should double the input");
        
        beginTest("Another test");
        
        bool condition = myOtherFunction();
        expect(condition, "Function should return true");
    }
};

// Register the test
static MyFeatureTest myFeatureTest;
```

#### 2. Add Test File to CMakeLists.txt

```cmake
# In tests/CMakeLists.txt
target_sources(UnitTests
    PRIVATE
        TestMain.cpp
        PluginTests.cpp
        MyFeatureTest.cpp  # Add your test file here
)
```

### Test Types

#### Unit Tests

Test individual functions and classes in isolation:

```cpp
beginTest("DSP algorithm");
auto processor = createTestProcessor();
auto result = processor.processValue(1.0f);
expectWithinAbsoluteError(result, 2.0f, 0.001f, "Should double input");
```

#### Integration Tests

Test how components work together:

```cpp
beginTest("Plugin parameter changes");
plugin.setParameter(0, 0.5f);
plugin.prepareToPlay(44100.0, 512);
// Process audio and verify parameter effect
```

#### Performance Tests

Test performance characteristics:

```cpp
beginTest("Processing performance");
auto start = juce::Time::getHighResolutionTicks();
plugin.processBlock(buffer, midiBuffer);
auto elapsed = juce::Time::getHighResolutionTicks() - start;
expect(elapsed < maxAllowedTime, "Processing should be fast enough");
```

## 🔧 Debugging Tips

### Common Issues

1. **Breakpoints not hitting**:
   - Make sure you're building in Debug mode
   - Check that the code path is actually executed
   - Try adding `jassert(false)` to verify code execution

2. **Plugin not loading in DAW**:
   - Check the plugin was built successfully
   - Verify it's installed in the correct location
   - Check Console.app for error messages

3. **Tests failing**:
   - Run tests individually to isolate issues
   - Add debug prints to understand test data
   - Use the debugger to step through test code

### Best Practices

1. **Use Debug Builds**: Always use Debug builds for development
2. **Add Assertions**: Use `jassert()` for runtime checks
3. **Log Information**: Use `DBG()` macro for debug output
4. **Test Early**: Write tests as you develop features
5. **Mock Dependencies**: Use mocks for external dependencies

### JUCE Debugging Macros

```cpp
#if JUCE_DEBUG
    DBG("Debug message: " << someVariable);
    jassert(someCondition);  // Breaks in debugger if false
#endif

// Always active logging
Logger::writeToLog("Important message: " + someString);
```

### Memory Debugging

JUCE includes leak detection in debug builds:

```cpp
// Will report leaks at shutdown
juce::ScopedJuceInitialiser_GUI gui;
// Your code here
// Leaks reported when gui goes out of scope
```

## 🎯 Testing Strategy

1. **Start Small**: Begin with simple unit tests
2. **Test Core Logic**: Focus on DSP and algorithm tests  
3. **Add Integration Tests**: Test component interactions
4. **Performance Testing**: Ensure real-time performance
5. **Regression Testing**: Prevent bugs from returning

## 📊 Continuous Testing

Consider setting up automated testing:

- Run tests on every build
- Add performance benchmarks
- Test on different sample rates and buffer sizes
- Test parameter automation scenarios

Happy debugging and testing! 🎵
