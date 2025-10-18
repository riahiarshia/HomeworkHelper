import SwiftUI
import GoogleSignIn

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
                .onOpenURL { url in
                    // Handle Google Sign-In callback
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
    
    private func configureTestMode() {
        // Disable animations for UI testing
        UIView.setAnimationsEnabled(false)
        
        // Configure test data if needed
        if ProcessInfo.processInfo.environment["-uiLocale"] == "en_US" {
            // Set up test user data
            dataManager.currentUser = User(username: "TestUser", age: nil, grade: "8th grade", points: 100, streak: 5)
        }
    }
}
