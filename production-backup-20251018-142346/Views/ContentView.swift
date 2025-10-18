import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataManager: DataManager
    @StateObject private var authService = AuthenticationService()
    @StateObject private var subscriptionService = SubscriptionService.shared
    @State private var selectedTab = 0
    @State private var showPaywall = false
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        print("🏗️ ContentView init called")
    }
    
    private var needsOnboarding: Bool {
        guard let user = dataManager.currentUser else { return true }
        // User needs onboarding if they don't have grade set
        // (they should have grade set after completing onboarding)
        return user.grade == nil
    }
    
    private var shouldShowPaywall: Bool {
        // NEW: Show paywall for users without active subscription
        // Apple IAP manages the 7-day trial (one per Apple ID) - not us
        if !authService.isAuthenticated || needsOnboarding {
            return false
        }
        
        // Check subscription status
        switch subscriptionService.subscriptionStatus {
        case .trial:
            // During Apple IAP trial period - NO paywall, let them use the app
            return false
        case .active, .gracePeriod:
            // Active subscription - no paywall
            return false
        case .expired, .unknown:
            // No active subscription - SHOW paywall to subscribe through Apple IAP
            // Apple will offer free trial if eligible (first time per Apple ID)
            return true
        }
    }
    
    private var isSubscriptionExpired: Bool {
        switch subscriptionService.subscriptionStatus {
        case .expired, .unknown:
            return true
        default:
            return false
        }
    }
    
    var body: some View {
        let _ = print("🔍 ContentView render: isAuthenticated = \(authService.isAuthenticated), needsOnboarding = \(needsOnboarding), selectedTab = \(selectedTab)")
        
        Group {
            if !authService.isAuthenticated {
                // Show new authentication screen with SSO primary
                AuthenticationView()
                    .environmentObject(authService)
            } else if needsOnboarding {
                // Show profile setup after authentication
                ProfileSetupView()
                    .environmentObject(dataManager)
                    .onDisappear {
                        // Reset to home tab when profile setup completes
                        selectedTab = 0
                    }
            } else {
                // Show main app
                TabView(selection: $selectedTab) {
                    HomeView(isSubscriptionExpired: isSubscriptionExpired)
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                        .tag(0)
                    
                    ProblemsListView(isSubscriptionExpired: isSubscriptionExpired)
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
                .onAppear {
                    // Configure tab bar appearance
                    let appearance = UITabBarAppearance()
                    appearance.configureWithOpaqueBackground()
                    appearance.backgroundColor = UIColor.white
                    
                    // Set selected and unselected item colors
                    appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
                    appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray]
                    
                    appearance.stackedLayoutAppearance.selected.iconColor = UIColor.systemBlue
                    appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemBlue]
                    
                    UITabBar.appearance().standardAppearance = appearance
                    UITabBar.appearance().scrollEdgeAppearance = appearance
                }
                .fullScreenCover(isPresented: $showPaywall) {
                    PaywallView()
                        .interactiveDismissDisabled() // Prevent dismissing - must subscribe
                }
                .environmentObject(authService)
                .environmentObject(subscriptionService)
            }
        }
        .onChange(of: authService.currentUser) { user in
            // Sync authenticated user to DataManager
            if let authUser = user {
                syncAuthUserToDataManager(authUser)
                
                // Load subscription status after user logs in
                Task {
                    print("🔐 User authenticated - Refreshing subscription status")
                    await subscriptionService.refreshSubscriptionStatus()
                    print("🔐 Post-auth subscription status: \(subscriptionService.subscriptionStatus)")
                }
            }
        }
        .onChange(of: scenePhase) { newPhase in
            handleScenePhaseChange(newPhase)
        }
        .onChange(of: needsOnboarding) { needs in
            // When onboarding is complete, ensure Home tab is selected
            if !needs {
                selectedTab = 0
                print("✅ Onboarding complete - setting tab to Home (0)")
                
                // Load subscription status after onboarding
                Task {
                    print("🔵 Post-onboarding - Refreshing subscription status")
                    await subscriptionService.refreshSubscriptionStatus()
                    print("🔵 Post-onboarding - Subscription status: \(subscriptionService.subscriptionStatus)")
                    
                    // Check if we need to show paywall
                    if shouldShowPaywall {
                        print("🔵 Post-onboarding - Should show paywall: TRUE")
                        showPaywall = true
                    } else {
                        print("🔵 Post-onboarding - Should show paywall: FALSE")
                    }
                }
            }
        }
        .onAppear {
            print("🔵 ContentView onAppear - Starting subscription refresh")
            
            // Sync on app launch if user is already authenticated
            if let authUser = authService.currentUser {
                syncAuthUserToDataManager(authUser)
            }
            
            // Load subscription status
            Task {
                print("🔵 ContentView - Calling refreshSubscriptionStatus()")
                await subscriptionService.refreshSubscriptionStatus()
                print("🔵 ContentView - Subscription status after refresh: \(subscriptionService.subscriptionStatus)")
                
                // Check if we need to show paywall after loading status
                if shouldShowPaywall {
                    print("🔵 ContentView - Should show paywall: TRUE")
                    showPaywall = true
                } else {
                    print("🔵 ContentView - Should show paywall: FALSE")
                }
            }
        }
        .onChange(of: subscriptionService.subscriptionStatus) { _ in
            // Show paywall if subscription expired
            if shouldShowPaywall {
                showPaywall = true
            } else {
                // Hide paywall if subscription becomes active
                showPaywall = false
            }
        }
        .onChange(of: scenePhase) { newPhase in
            // Refresh subscription status when app becomes active
            if newPhase == .active && authService.isAuthenticated {
                Task {
                    print("🔄 App became active - Refreshing subscription status")
                    await subscriptionService.refreshSubscriptionStatus()
                    print("🔄 Subscription status after app activation: \(subscriptionService.subscriptionStatus)")
                }
            }
        }
    }
    
    private func handleScenePhaseChange(_ newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            // App became active - data is already saved and session validation happens automatically
            print("📱 App became active")
        case .background:
            // Save data when app goes to background
            dataManager.saveData()
            print("💾 App went to background - data saved")
        case .inactive:
            print("📱 App became inactive")
        @unknown default:
            break
        }
    }
    
    private func syncAuthUserToDataManager(_ authUser: User) {
        // Update or create user in DataManager
        if dataManager.currentUser == nil {
            // No existing user, create from auth
            dataManager.currentUser = authUser
            print("✅ Created new user in DataManager from auth")
        } else {
            // CRITICAL: Preserve username and grade from DataManager
            // These are set during profile setup and should NOT be overwritten
            let existingUsername = dataManager.currentUser?.username
            let existingGrade = dataManager.currentUser?.grade
            
            // Update existing user with auth info
            dataManager.currentUser?.userId = authUser.userId
            dataManager.currentUser?.email = authUser.email
            dataManager.currentUser?.authToken = authUser.authToken
            dataManager.currentUser?.subscriptionStatus = authUser.subscriptionStatus
            dataManager.currentUser?.subscriptionEndDate = authUser.subscriptionEndDate
            dataManager.currentUser?.daysRemaining = authUser.daysRemaining
            
            // Restore profile data if it exists
            if let username = existingUsername {
                dataManager.currentUser?.username = username
            }
            if let grade = existingGrade {
                dataManager.currentUser?.grade = grade
            }
            
            print("✅ Updated existing user in DataManager with auth info (preserved username: \(existingUsername ?? "nil"), grade: \(existingGrade ?? "nil"))")
        }
        dataManager.saveData()
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(AuthenticationService())
        .environmentObject(DataManager.shared)
        .environmentObject(SubscriptionService.shared)
}
