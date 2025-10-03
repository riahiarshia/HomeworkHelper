# Homework Helper Test Suite

This directory contains a comprehensive test setup for the Homework Helper iOS app, including both Unit Tests and UI Tests.

## 📁 Directory Structure

```
Tests/
├── HomeworkHelperTests/           # Unit Tests
│   ├── HomeworkHelperTests.swift
│   └── OpenAIServiceTests.swift
├── HomeworkHelperUITests/         # UI Tests
│   └── SmokeUITests.swift
├── Shared/                        # Shared Test Utilities
│   ├── NetworkStub/
│   │   └── URLProtocolStub.swift
│   └── TestHelpers/
│       └── JSONLoader.swift
├── Fixtures/                      # Test Data
│   ├── mock_openai_response.json
│   └── mock_user_data.json
├── AppTests.xctestplan           # Test Plan Configuration
└── README.md                     # This file
```

## 🧪 Test Types

### Unit Tests (`HomeworkHelperTests`)
- **Model Tests**: User, HomeworkProblem, GuidanceStep creation and validation
- **DataManager Tests**: Singleton pattern, data persistence, problem management
- **KeychainHelper Tests**: Secure API key storage and retrieval
- **OpenAIService Tests**: Network mocking, API responses, error handling
- **Performance Tests**: JSON encoding, data management operations

### UI Tests (`HomeworkHelperUITests`)
- **Smoke Tests**: App launch, tab navigation, basic UI element verification
- **Home View Tests**: Camera/photo library buttons, text input, analyze button
- **Settings Tests**: API key field interaction, navigation
- **Progress Tests**: Statistics display, chart elements
- **Accessibility Tests**: Element identification, user interaction flows

## 🚀 Running Tests

### Quick Start - Run All Tests
```bash
# From the project root directory
bash scripts/test_all.sh
```

This script will:
- ✅ Detect your Xcode project automatically
- 🚀 Open Simulator app (always visible)
- 📱 Boot the appropriate iOS simulator
- 🧪 Run both unit and UI tests
- 📊 Generate detailed test results
- 💡 Keep simulator open for inspection

### Manual Test Execution

#### Run Unit Tests Only
```bash
xcodebuild test \
  -project HomeworkHelper.xcodeproj \
  -scheme HomeworkHelper \
  -only-testing:HomeworkHelperTests
```

#### Run UI Tests Only
```bash
xcodebuild test \
  -project HomeworkHelper.xcodeproj \
  -scheme HomeworkHelper \
  -only-testing:HomeworkHelperUITests
```

#### Run on Specific Simulator
```bash
# List available simulators
xcrun simctl list devices available

# Run on specific simulator
xcodebuild test \
  -project HomeworkHelper.xcodeproj \
  -scheme HomeworkHelper \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'
```

## 📊 Viewing Test Results

After running tests, results are saved to `TestResults/` directory:

```bash
# Open the most recent test results
open TestResults/*.xcresult

# Or open a specific result bundle
open TestResults/20240101_120000.xcresult
```

## 🔧 Test Configuration

### Test Plan (`AppTests.xctestplan`)
The test plan is configured to:
- Run both unit and UI test targets
- Use English (US) locale for consistent testing
- Enable UI test mode with `-uiTest` argument
- Support parallel execution for unit tests
- Sequential execution for UI tests (required for simulator)

### Test Mode Features
When running in test mode (`-uiTest` argument):
- 🎬 Animations are disabled for faster, more reliable UI tests
- 🧪 Test data is automatically loaded
- 📱 Simulator remains visible throughout test execution
- 🔐 Mock API responses are used (no real API calls)

## 🛠️ Test Utilities

### URLProtocolStub
Intercepts network requests for testing:
```swift
// Mock OpenAI API response
URLProtocolStub.setupMockOpenAIResponse(
    for: "/chat/completions",
    jsonData: mockResponseData
)

// Clean up after tests
URLProtocolStub.removeAllStubs()
```

### JSONLoader
Load test fixtures and mock data:
```swift
// Load JSON fixture
let mockData = try JSONLoader.loadJSON(named: "mock_openai_response")

// Load and decode JSON
let user = try JSONLoader.loadJSON(named: "mock_user_data", as: User.self)
```

## 🎯 Accessibility Testing

The app includes accessibility identifiers for UI testing:
- `home_view` - Main home view container
- `graduation_cap` - App icon
- `camera_button` - Camera capture button
- `photo_library_button` - Photo library button
- `analyze_button` - Problem analysis button

## 📱 Simulator Requirements

Tests are designed to work with:
- **iOS 16.0+** (matches app deployment target)
- **iPhone simulators** (iPhone 15, iPhone 14, iPhone SE)
- **Visible simulator** (never runs headless)

## 🔍 Troubleshooting

### Common Issues

1. **"No schemes found"**
   - Ensure you're in the project root directory
   - Verify `HomeworkHelper.xcodeproj` exists

2. **"No iOS simulators found"**
   - Install iOS simulators via Xcode → Preferences → Components
   - Run `xcrun simctl list devices available` to verify

3. **UI tests failing**
   - Ensure simulator is visible (not minimized)
   - Check that accessibility identifiers are properly set
   - Verify test mode is enabled (`-uiTest` argument)

4. **Network tests failing**
   - Tests use mocked responses, no internet required
   - Check that `URLProtocolStub` is properly configured

### Debug Commands
```bash
# Check available simulators
xcrun simctl list devices

# Reset simulator
xcrun simctl erase all

# Check Xcode project structure
xcodebuild -list -project HomeworkHelper.xcodeproj
```

## 📈 Performance Testing

The test suite includes performance benchmarks:
- **JSON Encoding**: Measures serialization performance
- **Data Management**: Tests bulk data operations
- **App Launch**: Measures startup time
- **Tab Switching**: Tests navigation performance

## 🎉 Success Criteria

Tests pass when:
- ✅ All unit tests complete successfully
- ✅ UI tests navigate through all main screens
- ✅ Simulator remains visible throughout execution
- ✅ Test results are generated and accessible
- ✅ No crashes or unexpected failures occur

## 📚 Additional Resources

- [Apple XCTest Documentation](https://developer.apple.com/documentation/xctest)
- [XCUITest Guide](https://developer.apple.com/documentation/xctest/xcuitest)
- [iOS Simulator Documentation](https://developer.apple.com/documentation/xcode/running-your-app-in-the-simulator)
