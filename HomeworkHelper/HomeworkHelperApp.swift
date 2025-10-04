import SwiftUI

@main
struct HomeworkHelperApp: App {
    @StateObject private var dataManager = DataManager.shared
    
    init() {
        // Configure test mode if UI testing arguments are present
        if ProcessInfo.processInfo.arguments.contains("-uiTest") {
            configureTestMode()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
        }
    }
    
    private func configureTestMode() {
        // Disable animations for UI testing
        UIView.setAnimationsEnabled(false)
        
        // Configure test data if needed
        if ProcessInfo.processInfo.environment["-uiLocale"] == "en_US" {
            // Set up test user data
            dataManager.currentUser = User(username: "TestUser", age: 12, grade: nil, points: 100, streak: 5)
        }
    }
}
