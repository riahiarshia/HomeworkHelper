import Foundation
import GoogleSignIn
import UIKit
import AuthenticationServices
import CryptoKit

class AuthenticationService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let backendURL = "https://homework-helper-api.azurewebsites.net"
    private let keychain = KeychainHelper.shared
    private var lastValidationTime: Date?
    private let validationInterval: TimeInterval = 10 // 10 seconds for immediate detection
    
    // Apple Sign-In
    private var currentNonce: String?
    
    // Device Information
    private func getDeviceInfo() -> [String: Any] {
        let device = UIDevice.current
        
        return [
            "deviceId": device.identifierForVendor?.uuidString ?? "unknown",
            "deviceModel": device.model,
            "deviceName": device.name,
            "systemVersion": device.systemVersion,
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown",
            "appBuild": Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown",
            "platform": "iOS"
        ]
    }
    
    init() {
        // Check if user is already authenticated
        loadSavedUser()
        
        // Listen for app becoming active to validate session
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        // Also listen for app entering foreground
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func appDidBecomeActive() {
        validateIfNeeded(trigger: "app became active")
    }
    
    @objc private func appWillEnterForeground() {
        validateIfNeeded(trigger: "app entering foreground")
    }
    
    private func validateIfNeeded(trigger: String) {
        // Only validate if user is authenticated
        guard isAuthenticated else { 
            print("⏭️ Skipping validation (\(trigger)) - not authenticated")
            return 
        }
        
        // TEMPORARILY DISABLED THROTTLE FOR DEBUGGING
        // Check if we need to validate (avoid too frequent validations)
        // if let lastValidation = lastValidationTime,
        //    Date().timeIntervalSince(lastValidation) < validationInterval {
        //     let elapsed = Date().timeIntervalSince(lastValidation)
        //     print("⏭️ Skipping validation (\(trigger)) - last check was \(Int(elapsed))s ago (need \(Int(validationInterval))s)")
        //     return
        // }
        
        print("🔄 Validation triggered: \(trigger)")
        print("🔍 Current user: \(currentUser?.email ?? "nil")")
        print("🔍 Is authenticated: \(isAuthenticated)")
        
        Task {
            await revalidateSession()
        }
    }
    
    // Public method to force validation
    func revalidateSession() async {
        guard let token = keychain.load(forKey: "authToken") else {
            print("⚠️ No token found for revalidation")
            return
        }
        
        await validateSession(token: token)
    }
    
    // MARK: - Email/Password Authentication
    
    func signInWithEmail(email: String, password: String) {
        guard !email.isEmpty, !password.isEmpty else {
            self.errorMessage = "Please enter email and password"
            return
        }
        
        guard email.contains("@") else {
            self.errorMessage = "Please enter a valid email address"
            return
        }
        
        guard password.count >= 6 else {
            self.errorMessage = "Password must be at least 6 characters"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        print("📧 Email sign-in attempt: \(email)")
        
        authenticateWithBackendEmail(email: email, password: password)
    }
    
    func signUpWithEmail(email: String, password: String, username: String) {
        guard !email.isEmpty, !password.isEmpty, !username.isEmpty else {
            self.errorMessage = "Please fill in all fields"
            return
        }
        
        guard email.contains("@") else {
            self.errorMessage = "Please enter a valid email address"
            return
        }
        
        guard password.count >= 6 else {
            self.errorMessage = "Password must be at least 6 characters"
            return
        }
        
        guard username.count >= 2 else {
            self.errorMessage = "Name must be at least 2 characters"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        print("📧 Email sign-up attempt: \(email)")
        
        registerWithBackendEmail(email: email, password: password, username: username)
    }
    
    private func authenticateWithBackendEmail(email: String, password: String) {
        guard let url = URL(string: "\(backendURL)/api/auth/login") else {
            self.errorMessage = "Invalid backend URL"
            self.isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "email": email.lowercased(),
            "password": password
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        print("📤 Sending email authentication request to backend...")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    print("❌ Backend email authentication error: \(error)")
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received from server"
                    return
                }
                
                // Check HTTP status code
                if let httpResponse = response as? HTTPURLResponse {
                    print("🔍 HTTP Status Code: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode == 401 {
                        self.errorMessage = "Invalid email or password"
                        return
                    }
                    
                    if httpResponse.statusCode == 403 {
                        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let error = json["error"] as? String {
                            self.errorMessage = error
                            return
                        }
                    }
                    
                    if httpResponse.statusCode != 200 {
                        self.errorMessage = "Login failed. Please try again."
                        return
                    }
                }
                
                self.handleAuthenticationResponse(data: data, authType: "email")
            }
        }.resume()
    }
    
    private func registerWithBackendEmail(email: String, password: String, username: String) {
        guard let url = URL(string: "\(backendURL)/api/auth/register") else {
            self.errorMessage = "Invalid backend URL"
            self.isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "email": email.lowercased(),
            "password": password,
            "username": username
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        print("📤 Sending registration request to backend...")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    print("❌ Backend registration error: \(error)")
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received from server"
                    return
                }
                
                // Check HTTP status code
                if let httpResponse = response as? HTTPURLResponse {
                    print("🔍 HTTP Status Code: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode == 400 {
                        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let error = json["error"] as? String {
                            self.errorMessage = error
                            return
                        }
                    }
                    
                    if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 {
                        self.errorMessage = "Registration failed. Please try again."
                        return
                    }
                }
                
                self.handleAuthenticationResponse(data: data, authType: "email")
            }
        }.resume()
    }
    
    private func handleAuthenticationResponse(data: Data, authType: String) {
        do {
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                self.errorMessage = "Invalid response format"
                return
            }
            
            if let error = json["error"] as? String {
                self.errorMessage = error
                return
            }
            
            guard let userId = json["userId"] as? String,
                  let userEmail = json["email"] as? String,
                  let token = json["token"] as? String else {
                self.errorMessage = "Missing required fields in response"
                return
            }
            
            let subscriptionStatus = json["subscription_status"] as? String
            let daysRemaining = json["days_remaining"] as? Int
            let userName = json["username"] as? String
            
            var subscriptionEndDate: Date?
            if let endDateString = json["subscription_end_date"] as? String {
                let formatter = ISO8601DateFormatter()
                subscriptionEndDate = formatter.date(from: endDateString)
            }
            
            print("✅ \(authType) authentication successful!")
            print("   User ID: \(userId)")
            print("   Email: \(userEmail)")
            
            let user = User(
                username: userName ?? "User",
                userId: userId,
                email: userEmail,
                authToken: token,
                subscriptionStatus: subscriptionStatus,
                subscriptionEndDate: subscriptionEndDate,
                daysRemaining: daysRemaining
            )
            
            self.saveUser(user)
            self.currentUser = user
            self.isAuthenticated = true
            
            Task {
                await self.validateSession(token: token)
            }
            
        } catch {
            self.errorMessage = "Failed to parse response: \(error.localizedDescription)"
            print("❌ JSON parsing error: \(error)")
        }
    }
    
    // MARK: - Apple Sign-In
    
    func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                self.errorMessage = "Invalid Apple ID credential"
                return
            }
            
            // Extract token
            guard let appleIDToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                self.errorMessage = "Invalid Apple ID token"
                print("❌ Failed to extract Apple ID token")
                return
            }
            
            // Extract user information
            let userIdentifier = appleIDCredential.user
            let email = appleIDCredential.email
            let fullName = appleIDCredential.fullName
            
            // Create display name
            var displayName = "Apple User"
            if let fullName = fullName {
                let firstName = fullName.givenName ?? ""
                let lastName = fullName.familyName ?? ""
                displayName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
                if displayName.isEmpty {
                    displayName = "Apple User"
                }
            }
            
            print("✅ Apple Sign-In successful: \(userIdentifier)")
            print("   Email: \(email ?? "not provided")")
            print("   Name: \(displayName)")
            print("   Token: \(idTokenString.prefix(20))...")
            
            isLoading = true
            errorMessage = nil
            
            // Send to backend
            authenticateWithBackendApple(
                userIdentifier: userIdentifier,
                email: email,
                name: displayName,
                appleIDToken: idTokenString
            )
            
        case .failure(let error):
            print("❌ Apple Sign-In error: \(error)")
            self.errorMessage = "Apple Sign-In failed: \(error.localizedDescription)"
        }
    }
    
    private func randomNonce(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
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
    
    // MARK: - Backend Authentication (Apple)
    
    private func authenticateWithBackendApple(userIdentifier: String, email: String?, name: String, appleIDToken: String) {
        guard let url = URL(string: "\(backendURL)/api/auth/apple") else {
            self.errorMessage = "Invalid backend URL"
            self.isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "userIdentifier": userIdentifier,
            "email": email ?? "",
            "name": name,
            "appleIDToken": appleIDToken,
            "deviceInfo": getDeviceInfo()
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            self.errorMessage = "Failed to encode request"
            self.isLoading = false
            return
        }
        
        print("📤 Sending Apple authentication request to backend...")
        print("🔍 URL: \(url.absoluteString)")
        print("🔍 User ID: \(userIdentifier)")
        print("🔍 Email: \(email ?? "none")")
        print("🔍 Name: \(name)")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    print("❌ Backend Apple authentication error: \(error)")
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received from server"
                    return
                }
                
                // Check HTTP status code
                if let httpResponse = response as? HTTPURLResponse {
                    print("🔍 HTTP Status Code: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode == 403 {
                        // Account is banned or inactive
                        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let error = json["error"] as? String {
                            self.errorMessage = error
                            if let reason = json["reason"] as? String {
                                self.errorMessage = "\(error)\nReason: \(reason)"
                            }
                            print("❌ Account blocked: \(error)")
                            // Clear any saved credentials since account is blocked
                            self.signOut()
                            return
                        }
                    }
                    
                    if httpResponse.statusCode == 500 {
                        // Server error - show more helpful message
                        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let error = json["error"] as? String {
                            self.errorMessage = "Server error: \(error). Please try again."
                            print("❌ Server error during Apple authentication: \(error)")
                            return
                        }
                    }
                    
                    if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 {
                        // Handle other error status codes
                        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let error = json["error"] as? String {
                            self.errorMessage = error
                            print("❌ Apple authentication failed with status \(httpResponse.statusCode): \(error)")
                            return
                        } else {
                            self.errorMessage = "Authentication failed. Please try again."
                            print("❌ Apple authentication failed with status \(httpResponse.statusCode)")
                            return
                        }
                    }
                }
                
                // Debug: Print response
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📥 Backend Apple response: \(responseString)")
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
                        if let reason = json["reason"] as? String {
                            self.errorMessage = "\(error)\nReason: \(reason)"
                        }
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
                    
                    print("✅ Apple authentication successful!")
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
                    
                    // Validate session immediately after login to check account status
                    Task {
                        print("🔄 Validating newly authenticated Apple user...")
                        await self.validateSession(token: token)
                    }
                    
                } catch {
                    self.errorMessage = "Failed to parse response: \(error.localizedDescription)"
                    print("❌ JSON parsing error: \(error)")
                }
            }
        }.resume()
    }
    
    // MARK: - Backend Authentication (Google)
    
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
            "googleIdToken": googleIdToken ?? "",
            "deviceInfo": getDeviceInfo()
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
                
                // Check HTTP status code
                if let httpResponse = response as? HTTPURLResponse {
                    print("🔍 HTTP Status Code: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode == 403 {
                        // Account is banned or inactive
                        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let error = json["error"] as? String {
                            self.errorMessage = error
                            if let reason = json["reason"] as? String {
                                self.errorMessage = "\(error)\nReason: \(reason)"
                            }
                            print("❌ Account blocked: \(error)")
                            return
                        }
                    }
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
                        if let reason = json["reason"] as? String {
                            self.errorMessage = "\(error)\nReason: \(reason)"
                        }
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
                    
                    // Validate session immediately after login to check account status
                    Task {
                        print("🔄 Validating newly authenticated user...")
                        await self.validateSession(token: token)
                    }
                    
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
        print("🔍 URL: \(url.absoluteString)")
        print("🔍 Token: \(token.prefix(20))...")
        
        // Record validation attempt time
        await MainActor.run {
            self.lastValidationTime = Date()
        }
        
        do {
            print("🔍 Sending request...")
            let (data, response) = try await URLSession.shared.data(for: request)
            print("🔍 Received response")
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("⚠️ Invalid response from server")
                return
            }
            
            print("🔍 Status code: \(httpResponse.statusCode)")
            
            // Print response body for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("🔍 Response body: \(responseString)")
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
            print("❌ Session validation network error: \(error.localizedDescription)")
            print("❌ Error details: \(error)")
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

