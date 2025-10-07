import Foundation
import GoogleSignIn
import UIKit

class AuthenticationService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let backendURL = "https://homework-helper-api.azurewebsites.net"
    private let keychain = KeychainHelper.shared
    
    init() {
        // Check if user is already authenticated
        loadSavedUser()
    }
    
    // MARK: - Google Sign-In
    
    func signInWithGoogle() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            self.errorMessage = "Could not find root view controller"
            return
        }
        
        // Get client ID from GoogleService-Info.plist
        guard let clientID = getGoogleClientID() else {
            self.errorMessage = "Google Sign-In not configured. Please add GoogleService-Info.plist"
            return
        }
        
        // Configure Google Sign-In
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        isLoading = true
        errorMessage = nil
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.isLoading = false
                    self.errorMessage = "Google Sign-In failed: \(error.localizedDescription)"
                    print("❌ Google Sign-In error: \(error)")
                    return
                }
                
                guard let user = result?.user,
                      let email = user.profile?.email,
                      let name = user.profile?.name else {
                    self.isLoading = false
                    self.errorMessage = "Could not get user information from Google"
                    return
                }
                
                print("✅ Google Sign-In successful: \(email)")
                
                // Send to backend
                self.authenticateWithBackend(email: email, name: name, googleIdToken: user.idToken?.tokenString)
            }
        }
    }
    
    // MARK: - Backend Authentication
    
    private func authenticateWithBackend(email: String, name: String, googleIdToken: String?) {
        guard let url = URL(string: "\(backendURL)/api/auth/google") else {
            self.errorMessage = "Invalid backend URL"
            self.isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "email": email,
            "name": name,
            "googleIdToken": googleIdToken ?? ""
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            self.errorMessage = "Failed to encode request"
            self.isLoading = false
            return
        }
        
        print("📤 Sending authentication request to backend...")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    print("❌ Backend authentication error: \(error)")
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received from server"
                    return
                }
                
                // Debug: Print response
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📥 Backend response: \(responseString)")
                }
                
                // Parse response
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                        self.errorMessage = "Invalid response format"
                        return
                    }
                    
                    // Check for error in response
                    if let error = json["error"] as? String {
                        self.errorMessage = error
                        print("❌ Backend error: \(error)")
                        return
                    }
                    
                    // Extract user data
                    guard let userId = json["userId"] as? String,
                          let userEmail = json["email"] as? String,
                          let token = json["token"] as? String else {
                        self.errorMessage = "Missing required fields in response"
                        return
                    }
                    
                    let subscriptionStatus = json["subscription_status"] as? String
                    let daysRemaining = json["days_remaining"] as? Int
                    
                    // Parse subscription end date
                    var subscriptionEndDate: Date?
                    if let endDateString = json["subscription_end_date"] as? String {
                        let formatter = ISO8601DateFormatter()
                        subscriptionEndDate = formatter.date(from: endDateString)
                    }
                    
                    print("✅ Authentication successful!")
                    print("   User ID: \(userId)")
                    print("   Email: \(userEmail)")
                    print("   Subscription: \(subscriptionStatus ?? "unknown")")
                    print("   Days remaining: \(daysRemaining ?? 0)")
                    
                    // Create user object
                    let user = User(
                        username: name,
                        userId: userId,
                        email: userEmail,
                        authToken: token,
                        subscriptionStatus: subscriptionStatus,
                        subscriptionEndDate: subscriptionEndDate,
                        daysRemaining: daysRemaining
                    )
                    
                    // Save to keychain and local state
                    self.saveUser(user)
                    self.currentUser = user
                    self.isAuthenticated = true
                    
                    print("🔄 State updated: isAuthenticated = \(self.isAuthenticated)")
                    print("🔄 Current user: \(self.currentUser?.email ?? "nil")")
                    
                } catch {
                    self.errorMessage = "Failed to parse response: \(error.localizedDescription)"
                    print("❌ JSON parsing error: \(error)")
                }
            }
        }.resume()
    }
    
    // MARK: - User Persistence
    
    private func saveUser(_ user: User) {
        // Save token to keychain
        if let token = user.authToken {
            _ = keychain.save(token, forKey: "authToken")
        }
        
        // Save user data
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "savedUser")
        }
        
        print("💾 User data saved")
    }
    
    private func loadSavedUser() {
        // Load user from UserDefaults
        guard let data = UserDefaults.standard.data(forKey: "savedUser"),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            print("ℹ️ No saved user found")
            return
        }
        
        // Verify token exists in keychain
        guard let token = keychain.load(forKey: "authToken") else {
            print("⚠️ Token not found in keychain, user session expired")
            return
        }
        
        print("✅ Loaded saved user: \(user.email ?? "unknown")")
        
        // Temporarily set user as authenticated while we validate
        self.currentUser = user
        self.isAuthenticated = true
        
        // Validate session with backend (async)
        Task {
            await validateSession(token: token)
        }
    }
    
    // MARK: - Session Validation
    
    private func validateSession(token: String) async {
        guard let url = URL(string: "\(backendURL)/api/auth/validate-session") else {
            print("⚠️ Invalid validation URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("📤 Validating session with backend...")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("⚠️ Invalid response from server")
                return
            }
            
            if httpResponse.statusCode == 200 {
                // Parse successful response
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let valid = json["valid"] as? Bool,
                   valid,
                   let userData = json["user"] as? [String: Any] {
                    
                    // Update user data with latest from server
                    await MainActor.run {
                        if var user = self.currentUser {
                            // Update subscription info
                            user.subscriptionStatus = userData["subscriptionStatus"] as? String
                            user.daysRemaining = userData["daysRemaining"] as? Int
                            
                            if let endDateString = userData["subscriptionEndDate"] as? String {
                                let formatter = ISO8601DateFormatter()
                                user.subscriptionEndDate = formatter.date(from: endDateString)
                            }
                            
                            self.currentUser = user
                            self.saveUser(user)
                            
                            print("✅ Session validated successfully")
                            print("   Subscription: \(user.subscriptionStatus ?? "unknown")")
                            print("   Days remaining: \(user.daysRemaining ?? 0)")
                        }
                    }
                }
            } else if httpResponse.statusCode == 403 {
                // User is banned or inactive
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let error = json["error"] as? String {
                    
                    print("❌ Session validation failed: \(error)")
                    
                    await MainActor.run {
                        // Sign out user
                        self.errorMessage = error
                        self.signOut()
                        
                        // Show alert to user
                        if let reason = json["reason"] as? String {
                            self.errorMessage = "\(error). Reason: \(reason)"
                        }
                    }
                }
            } else if httpResponse.statusCode == 404 {
                // User not found in database
                print("❌ User not found in database")
                await MainActor.run {
                    self.errorMessage = "Account not found. Please sign in again."
                    self.signOut()
                }
            } else if httpResponse.statusCode == 401 {
                // Token expired or invalid
                print("❌ Token expired or invalid")
                await MainActor.run {
                    self.errorMessage = "Session expired. Please sign in again."
                    self.signOut()
                }
            }
            
        } catch {
            print("⚠️ Session validation network error: \(error.localizedDescription)")
            // Don't sign out on network errors - user can still use the app
            // The validation will happen again next time they have connectivity
        }
    }
    
    // MARK: - Sign Out
    
    func signOut() {
        // Sign out from Google
        GIDSignIn.sharedInstance.signOut()
        
        // Clear keychain
        _ = keychain.delete(forKey: "authToken")
        
        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: "savedUser")
        
        // Clear state
        currentUser = nil
        isAuthenticated = false
        
        print("👋 User signed out")
    }
    
    // MARK: - Helpers
    
    private func getGoogleClientID() -> String? {
        // Try to get from GoogleService-Info.plist
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path),
           let clientID = dict["CLIENT_ID"] as? String {
            return clientID
        }
        
        // Fallback to hardcoded (from your plist file)
        return "512059909634-l5u3o9uej9n9jo02k9pt7iko465q7aem.apps.googleusercontent.com"
    }
}

