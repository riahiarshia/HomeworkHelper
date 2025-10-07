import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataManager: DataManager
    @StateObject private var authService = AuthenticationService()
    @State private var selectedTab = 0
    
    private var needsOnboarding: Bool {
        guard let user = dataManager.currentUser else { return true }
        // User needs onboarding if they don't have both age AND grade set
        // (they should have at least one of them set after completing onboarding)
        return user.age == nil && user.grade == nil
    }
    
    var body: some View {
        let _ = print("🔍 ContentView render: isAuthenticated = \(authService.isAuthenticated), needsOnboarding = \(needsOnboarding), selectedTab = \(selectedTab)")
        
        return Group {
            if !authService.isAuthenticated {
                // Show authentication screen
                AuthenticationView()
            } else if needsOnboarding {
                // Show onboarding after authentication
                OnboardingView()
                    .environmentObject(dataManager)
                    .onDisappear {
                        // Reset to home tab when onboarding completes
                        selectedTab = 0
                    }
            } else {
                // Show main app
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                        .tag(0)
                    
                    ProblemsListView()
                        .tabItem {
                            Label("Problems", systemImage: "list.bullet")
                        }
                        .tag(1)
                    
                    ProgressStatsView()
                        .tabItem {
                            Label("Progress", systemImage: "chart.bar.fill")
                        }
                        .tag(2)
                    
                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                        .tag(3)
                }
            }
        }
        .environmentObject(authService)
        .onChange(of: authService.currentUser) { user in
            // Sync authenticated user to DataManager
            if let authUser = user {
                syncAuthUserToDataManager(authUser)
            }
        }
        .onChange(of: needsOnboarding) { needs in
            // When onboarding is complete, ensure Home tab is selected
            if !needs {
                selectedTab = 0
                print("✅ Onboarding complete - setting tab to Home (0)")
            }
        }
        .onAppear {
            // Sync on app launch if user is already authenticated
            if let authUser = authService.currentUser {
                syncAuthUserToDataManager(authUser)
            }
        }
    }
    
    private func syncAuthUserToDataManager(_ authUser: User) {
        // Update or create user in DataManager
        if dataManager.currentUser == nil {
            // No existing user, create from auth
            dataManager.currentUser = authUser
            print("✅ Created new user in DataManager from auth")
        } else {
            // Update existing user with auth info
            dataManager.currentUser?.userId = authUser.userId
            dataManager.currentUser?.email = authUser.email
            dataManager.currentUser?.authToken = authUser.authToken
            dataManager.currentUser?.subscriptionStatus = authUser.subscriptionStatus
            dataManager.currentUser?.subscriptionEndDate = authUser.subscriptionEndDate
            dataManager.currentUser?.daysRemaining = authUser.daysRemaining
            print("✅ Updated existing user in DataManager with auth info")
        }
        dataManager.saveData()
    }
}
