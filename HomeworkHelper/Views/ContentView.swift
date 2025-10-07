import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedTab = 0
    
    private var needsOnboarding: Bool {
        guard let user = dataManager.currentUser else { return true }
        // User needs onboarding if they don't have both age AND grade set
        // (they should have at least one of them set after completing onboarding)
        return user.age == nil && user.grade == nil
    }
    
    var body: some View {
        if needsOnboarding {
            OnboardingView()
                .environmentObject(dataManager)
        } else {
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
}
