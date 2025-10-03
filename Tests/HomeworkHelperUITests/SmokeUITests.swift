import XCTest

final class SmokeUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
        
        // Set test arguments for UI testing mode
        app.launchArguments = ["-uiTest", "1"]
        app.launchEnvironment = ["-uiLocale": "en_US"]
        
        // Handle permission alerts
        addUIInterruptionMonitor(withDescription: "Permission Alert") { (alert) -> Bool in
            if alert.buttons["Allow"].exists {
                alert.buttons["Allow"].tap()
                return true
            }
            if alert.buttons["OK"].exists {
                alert.buttons["OK"].tap()
                return true
            }
            if alert.buttons["Don't Allow"].exists {
                alert.buttons["Don't Allow"].tap()
                return true
            }
            return false
        }
        
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Basic App Launch Tests
    
    func testAppLaunchesSuccessfully() throws {
        // Verify the app launches without crashing
        XCTAssertTrue(app.state == .runningForeground)
    }
    
    func testHomeTabIsVisible() throws {
        // Check if the home tab is selected and visible
        let homeTab = app.tabBars.buttons["Home"]
        XCTAssertTrue(homeTab.waitForExistence(timeout: 5))
        XCTAssertTrue(homeTab.isSelected)
    }
    
    func testTabBarNavigation() throws {
        // Test navigation between tabs
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        
        // Test Problems tab
        let problemsTab = app.tabBars.buttons["Problems"]
        XCTAssertTrue(problemsTab.waitForExistence(timeout: 2))
        problemsTab.tap()
        XCTAssertTrue(problemsTab.isSelected)
        
        // Test Progress tab
        let progressTab = app.tabBars.buttons["Progress"]
        XCTAssertTrue(progressTab.waitForExistence(timeout: 2))
        progressTab.tap()
        XCTAssertTrue(progressTab.isSelected)
        
        // Test Settings tab
        let settingsTab = app.tabBars.buttons["Settings"]
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 2))
        settingsTab.tap()
        XCTAssertTrue(settingsTab.isSelected)
        
        // Return to Home
        let homeTab = app.tabBars.buttons["Home"]
        homeTab.tap()
        XCTAssertTrue(homeTab.isSelected)
    }
    
    // MARK: - Home View Tests
    
    func testHomeViewElements() throws {
        // Check for main home view elements
        let homeView = app.otherElements["home_view"]
        
        // Check for graduation cap icon
        let graduationIcon = app.images.matching(identifier: "graduation_cap").firstMatch
        XCTAssertTrue(graduationIcon.waitForExistence(timeout: 5))
        
        // Check for "Learn by Solving" text
        let learnText = app.staticTexts["Learn by Solving"]
        XCTAssertTrue(learnText.waitForExistence(timeout: 2))
        
        // Check for upload section
        let uploadText = app.staticTexts["Upload Your Homework"]
        XCTAssertTrue(uploadText.waitForExistence(timeout: 2))
    }
    
    func testCameraAndPhotoLibraryButtons() throws {
        // Test camera button
        let cameraButton = app.buttons["Camera"]
        XCTAssertTrue(cameraButton.waitForExistence(timeout: 5))
        
        // Test photo library button
        let photoLibraryButton = app.buttons["Photo Library"]
        XCTAssertTrue(photoLibraryButton.waitForExistence(timeout: 2))
        
        // Verify both buttons are enabled
        XCTAssertTrue(cameraButton.isEnabled)
        XCTAssertTrue(photoLibraryButton.isEnabled)
    }
    
    func testTextInputSection() throws {
        // Check for text input section
        let textInputLabel = app.staticTexts["Or type your problem:"]
        XCTAssertTrue(textInputLabel.waitForExistence(timeout: 2))
        
        // Check for text editor
        let textEditor = app.textViews.firstMatch
        XCTAssertTrue(textEditor.waitForExistence(timeout: 2))
        XCTAssertTrue(textEditor.isEnabled)
    }
    
    // MARK: - Settings View Tests
    
    func testSettingsViewNavigation() throws {
        // Navigate to Settings
        let settingsTab = app.tabBars.buttons["Settings"]
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()
        
        // Check for Settings title
        let settingsTitle = app.navigationBars["Settings"].firstMatch
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 2))
        
        // Check for OpenAI Configuration section
        let openAISection = app.staticTexts["OpenAI Configuration"]
        XCTAssertTrue(openAISection.waitForExistence(timeout: 2))
        
        // Check for API Key field
        let apiKeyField = app.secureTextFields["API Key"]
        XCTAssertTrue(apiKeyField.waitForExistence(timeout: 2))
    }
    
    func testSettingsAPIKeyField() throws {
        // Navigate to Settings
        let settingsTab = app.tabBars.buttons["Settings"]
        settingsTab.tap()
        
        // Test API Key field interaction
        let apiKeyField = app.secureTextFields["API Key"]
        XCTAssertTrue(apiKeyField.waitForExistence(timeout: 5))
        
        // Tap and type in the field
        apiKeyField.tap()
        apiKeyField.typeText("sk-test123456789")
        
        // Verify text was entered
        XCTAssertEqual(apiKeyField.value as? String, "••••••••••••••••••••••")
    }
    
    // MARK: - Problems List Tests
    
    func testProblemsListView() throws {
        // Navigate to Problems tab
        let problemsTab = app.tabBars.buttons["Problems"]
        XCTAssertTrue(problemsTab.waitForExistence(timeout: 5))
        problemsTab.tap()
        
        // Check for Problems title
        let problemsTitle = app.navigationBars["My Problems"]
        XCTAssertTrue(problemsTitle.waitForExistence(timeout: 2))
        
        // Check for filter picker
        let filterPicker = app.segmentedControls.firstMatch
        XCTAssertTrue(filterPicker.waitForExistence(timeout: 2))
    }
    
    // MARK: - Progress View Tests
    
    func testProgressView() throws {
        // Navigate to Progress tab
        let progressTab = app.tabBars.buttons["Progress"]
        XCTAssertTrue(progressTab.waitForExistence(timeout: 5))
        progressTab.tap()
        
        // Check for Progress title
        let progressTitle = app.navigationBars["Progress"]
        XCTAssertTrue(progressTitle.waitForExistence(timeout: 2))
        
        // Check for stats elements
        let totalPoints = app.staticTexts["Total Points"]
        XCTAssertTrue(totalPoints.waitForExistence(timeout: 2))
    }
    
    // MARK: - Text Input and Analysis Flow
    
    func testTextInputAndAnalysisFlow() throws {
        // Enter text in the problem input
        let textEditor = app.textViews.firstMatch
        XCTAssertTrue(textEditor.waitForExistence(timeout: 5))
        textEditor.tap()
        textEditor.typeText("Solve 2x + 3 = 7")
        
        // Check for analyze button
        let analyzeButton = app.buttons["Get Step-by-Step Help"]
        XCTAssertTrue(analyzeButton.waitForExistence(timeout: 2))
        XCTAssertTrue(analyzeButton.isEnabled)
        
        // Note: We don't actually tap the analyze button in UI tests
        // as it would require a real API key and network connection
        // In a real test environment, you would mock the API response
    }
    
    // MARK: - Accessibility Tests
    
    func testAccessibilityElements() throws {
        // Check that important elements have accessibility identifiers
        let homeTab = app.tabBars.buttons["Home"]
        XCTAssertTrue(homeTab.exists)
        
        let cameraButton = app.buttons["Camera"]
        XCTAssertTrue(cameraButton.exists)
        
        let photoLibraryButton = app.buttons["Photo Library"]
        XCTAssertTrue(photoLibraryButton.exists)
        
        let settingsTab = app.tabBars.buttons["Settings"]
        XCTAssertTrue(settingsTab.exists)
    }
    
    // MARK: - Performance Tests
    
    func testAppLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            app.launch()
        }
    }
    
    func testTabSwitchingPerformance() throws {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        
        measure {
            let tabs = ["Home", "Problems", "Progress", "Settings"]
            for tab in tabs {
                let tabButton = app.tabBars.buttons[tab]
                if tabButton.exists {
                    tabButton.tap()
                }
            }
        }
    }
}
