import Foundation
import StoreKit

/// Subscription Service using StoreKit 2
/// Handles In-App Purchase subscriptions following Apple best practices
@MainActor
class SubscriptionService: ObservableObject {
    static let shared = SubscriptionService()
    
    // MARK: - Published Properties
    @Published var subscriptionStatus: SubscriptionStatus = .unknown
    @Published var currentSubscription: Product?
    @Published var purchasedSubscriptions: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Subscription Status
    enum SubscriptionStatus: Equatable {
        case unknown
        case trial(daysRemaining: Int)
        case active(renewalDate: Date)
        case expired
        case gracePeriod(daysRemaining: Int) // User has payment issue but still has access
    }
    
    // MARK: - Product IDs (must match App Store Connect)
    private let monthlySubscriptionID = "com.homeworkhelper.monthly"
    
    // MARK: - Trial Configuration
    private let trialDurationDays = 7 // Default 7-day trial
    
    // MARK: - TestFlight Detection
    private var isTestFlight: Bool {
        #if DEBUG
        return true // Always true in debug builds
        #else
        return Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
        #endif
    }
    
    // MARK: - Transaction Listener
    private var updateListenerTask: Task<Void, Error>?
    
    // MARK: - Initialization
    private init() {
        print("🔧 SubscriptionService init - Starting initialization")
        
        // Start listening for transaction updates
        updateListenerTask = listenForTransactions()
        
        // Don't load subscription status here - it will be loaded when views appear
        // This is because the user might not be logged in yet when this singleton is created
        print("🔧 SubscriptionService init - Complete (subscription status will be loaded on demand)")
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Load Products
    func loadProducts() async {
        print("📦 Loading products...")
        print("📦 Environment: \(isTestFlight ? "Sandbox/TestFlight" : "Production")")
        isLoading = true
        errorMessage = nil
        
        do {
            // Request products from App Store (works in both sandbox and production)
            print("📦 Requesting product ID: \(monthlySubscriptionID)")
            let products = try await Product.products(for: [monthlySubscriptionID])
            
            if products.isEmpty {
                errorMessage = "No subscription products available. Please check your StoreKit Configuration."
                print("⚠️ No products found for ID: \(monthlySubscriptionID)")
                print("⚠️ Make sure StoreKit Configuration is set in Xcode scheme")
                print("⚠️ For sandbox testing, ensure Configuration.storekit file is selected in scheme settings")
            } else {
                currentSubscription = products.first
                print("✅ Loaded subscription product: \(products.first?.displayName ?? "Unknown")")
                print("   Price: \(products.first?.displayPrice ?? "Unknown")")
                print("   Description: \(products.first?.description ?? "Unknown")")
                print("   Product ID: \(products.first?.id ?? "Unknown")")
                
                if isTestFlight {
                    print("🧪 SANDBOX MODE - Ready for testing with sandbox Apple ID")
                    print("🧪 Sign out of App Store in Settings > App Store")
                    print("🧪 When purchasing, use your sandbox test account")
                }
            }
        } catch {
            errorMessage = "Failed to load subscription: \(error.localizedDescription)"
            print("❌ Error loading products: \(error)")
            print("❌ Error details: \(error)")
            print("❌ Error type: \(type(of: error))")
            
            if isTestFlight {
                print("🧪 SANDBOX ERROR TIPS:")
                print("   1. Check Configuration.storekit is selected in scheme")
                print("   2. Verify product ID matches: \(monthlySubscriptionID)")
                print("   3. Try cleaning build folder (Cmd+Shift+K)")
                print("   4. Restart Xcode if needed")
            }
        }
        
        isLoading = false
        print("📦 Product loading complete. Current subscription: \(currentSubscription != nil ? "Available" : "Not available")")
    }
    
    // MARK: - Purchase Subscription
    func purchase() async -> Bool {
        print("🛒 Purchase() called")
        print("🛒 Environment: \(isTestFlight ? "Sandbox" : "Production")")
        
        guard let product = currentSubscription else {
            errorMessage = "No subscription product available. Please wait for products to load."
            print("❌ No product available to purchase")
            print("❌ Try restarting the app or checking your connection")
            return false
        }
        
        print("🛒 Product found: \(product.displayName)")
        print("🛒 Product ID: \(product.id)")
        print("🛒 Price: \(product.displayPrice)")
        print("🎁 Trial Eligibility: Determined by Apple based on Apple ID")
        print("   → If first time: StoreKit will show '7 Days Free, then $9.99/month'")
        print("   → If already used trial: StoreKit will show '$9.99/month' only")
        print("   → Apple enforces this automatically - no custom code needed")
        isLoading = true
        errorMessage = nil
        
        do {
            // Attempt purchase
            print("🛒 Calling product.purchase()...")
            if isTestFlight {
                print("🧪 SANDBOX: You should see Apple's sandbox purchase dialog")
                print("🧪 SANDBOX: Use your sandbox test account (not your real Apple ID)")
            }
            
            let result = try await product.purchase()
            print("🛒 Purchase result received: \(result)")
            
            switch result {
            case .success(let verification):
                print("✅ Purchase successful, verifying transaction...")
                // Check transaction verification
                let transaction = try checkVerified(verification)
                print("✅ Transaction verified")
                print("✅ Transaction ID: \(transaction.id)")
                print("✅ Product ID: \(transaction.productID)")
                print("✅ Purchase Date: \(transaction.purchaseDate)")
                
                if isTestFlight {
                    print("🧪 SANDBOX: Transaction successful in sandbox environment")
                }
                
                // Update local subscription status
                await updateSubscriptionStatus(transaction: transaction)
                
                // CRITICAL: Validate receipt with backend (Industry best practice)
                await validateReceiptWithBackend(transaction: transaction)
                
                // Finish the transaction
                await transaction.finish()
                
                print("✅ Purchase complete!")
                isLoading = false
                return true
                
            case .userCancelled:
                print("ℹ️ User cancelled purchase")
                if isTestFlight {
                    print("🧪 SANDBOX: User cancelled the sandbox purchase dialog")
                }
                isLoading = false
                return false
                
            case .pending:
                print("⏳ Purchase pending (e.g., Ask to Buy)")
                errorMessage = "Purchase is pending approval"
                isLoading = false
                return false
                
            @unknown default:
                print("⚠️ Unknown purchase result")
                isLoading = false
                return false
            }
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            print("❌ Purchase error: \(error)")
            print("❌ Error type: \(type(of: error))")
            print("❌ Error details: \(error)")
            
            if isTestFlight {
                print("🧪 SANDBOX ERROR TROUBLESHOOTING:")
                print("   1. Sign OUT of App Store in Settings > App Store")
                print("   2. When prompted during purchase, sign in with sandbox account")
                print("   3. Make sure sandbox account is set up in App Store Connect")
                print("   4. Check that product ID matches in Configuration.storekit")
            }
            
            isLoading = false
            return false
        }
    }
    
    // MARK: - Restore Purchases
    func restorePurchases() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Sync with App Store
            try await AppStore.sync()
            
            // Always fetch fresh subscription status from backend
            await checkTrialStatus()
            
            print("✅ Purchases restored and subscription status refreshed from backend")
        } catch {
            errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
            print("❌ Restore error: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Public Methods
    
    /// Force refresh subscription status from backend AND Apple
    func refreshSubscriptionStatus() async {
        print("🔄 Force refreshing subscription status from Apple and backend...")
        print("🔄 Current status before refresh: \(subscriptionStatus)")
        
        // FIRST: Check with Apple/StoreKit for active subscriptions
        await checkCurrentEntitlements()
        
        // THEN: Fetch from backend to get days remaining calculation
        await checkTrialStatus()
        
        print("🔄 Current status after refresh: \(subscriptionStatus)")
    }
    
    /// Check current subscription entitlements with StoreKit and revalidate with backend
    /// NOTE: Apple enforces one free trial per Apple ID per subscription group
    /// Even if user deletes account and re-signs up, Apple won't offer trial again
    private func checkCurrentEntitlements() async {
        print("🔍 Checking current subscription entitlements with StoreKit...")
        print("   Apple enforces: One trial per Apple ID (prevents trial abuse)")
        
        // Check for active subscriptions
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                // Only process subscription transactions
                guard transaction.productType == .autoRenewable else { continue }
                
                // Check if this is our subscription product
                if transaction.productID == monthlySubscriptionID {
                    print("✅ Found active subscription: \(transaction.productID)")
                    print("   Transaction ID: \(transaction.id)")
                    print("   Original Transaction ID: \(transaction.originalID)")
                    print("   Purchase Date: \(transaction.purchaseDate)")
                    print("   Expiration Date: \(transaction.expirationDate?.description ?? "N/A")")
                    print("   Product Type: \(transaction.productType)")
                    
                    // Revalidate this receipt with backend to update database
                    // Backend will track trial usage by original_transaction_id
                    await validateReceiptWithBackend(transaction: transaction)
                    
                    print("✅ Subscription entitlement validated with backend")
                    return
                }
            } catch {
                print("❌ Failed to verify transaction: \(error)")
            }
        }
        
        print("ℹ️ No active subscription entitlements found in StoreKit")
        print("   If user has no active subscription, they'll see paywall")
        print("   Apple will determine if they're eligible for free trial")
    }
    
    /// Clear local subscription cache and force refresh from backend
    func clearCacheAndRefresh() async {
        print("🗑️ Clearing subscription cache and refreshing from backend...")
        subscriptionStatus = .unknown
        await refreshSubscriptionStatus()
    }
    
    /// Handle subscription status change (e.g., after cancellation)
    func handleSubscriptionChange() async {
        print("📱 Subscription status changed - refreshing from backend...")
        await clearCacheAndRefresh()
    }
    
    // MARK: - Load Subscription Status
    private func loadSubscriptionStatus() async {
        // Always fetch from backend - single source of truth
        print("🔄 Loading subscription status from backend (single source of truth)")
        await checkTrialStatus()
    }
    
    // MARK: - Update Subscription Status
    private func updateSubscriptionStatus(transaction: Transaction) async {
        guard let expirationDate = transaction.expirationDate else {
            subscriptionStatus = .expired
            return
        }
        
        let now = Date()
        
        if expirationDate > now {
            // Active subscription
            subscriptionStatus = .active(renewalDate: expirationDate)
            print("✅ Active subscription until: \(expirationDate)")
            
            // Sync with backend
            await syncSubscriptionWithBackend(status: "active", endDate: expirationDate)
        } else {
            // Check for grace period
            if let gracePeriodEnd = transaction.revocationDate {
                let daysRemaining = Calendar.current.dateComponents([.day], from: now, to: gracePeriodEnd).day ?? 0
                if daysRemaining > 0 {
                    subscriptionStatus = .gracePeriod(daysRemaining: daysRemaining)
                    print("⚠️ Grace period: \(daysRemaining) days remaining")
                } else {
                    subscriptionStatus = .expired
                    await syncSubscriptionWithBackend(status: "expired", endDate: nil)
                }
            } else {
                subscriptionStatus = .expired
                await syncSubscriptionWithBackend(status: "expired", endDate: nil)
            }
        }
    }
    
    // MARK: - Check Trial Status
    private func checkTrialStatus() async {
        print("🔍 checkTrialStatus() called")
        
        // Get trial info from backend
        guard let userId = getUserId(), let token = getAuthToken() else {
            print("❌ checkTrialStatus: No userId or token found")
            subscriptionStatus = .expired
            return
        }
        
        print("🔍 checkTrialStatus: userId=\(userId), making backend request...")
        
        do {
            let url = URL(string: "\(Config.apiBaseURL)/api/auth/validate-session")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Debug: Log the raw response
            if let responseString = String(data: data, encoding: .utf8) {
                print("🔍 Raw backend response: \(responseString)")
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("🔍 HTTP Status: \(httpResponse.statusCode)")
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                // The response has user data nested under "user" key
                if let userData = json["user"] as? [String: Any],
                   let subscriptionStatus = userData["subscriptionStatus"] as? String {
                
                    // Use days_remaining from backend (matches admin portal calculation)
                    let daysRemaining = userData["daysRemaining"] as? Int ?? 0
                
                    print("📊 Backend subscription data:")
                    print("   Status: \(subscriptionStatus)")
                    print("   Days remaining: \(daysRemaining)")
                    
                    print("🔍 Processing subscription status: '\(subscriptionStatus)', days: \(daysRemaining)")
                    
                    if subscriptionStatus == "trial" && daysRemaining > 0 {
                        self.subscriptionStatus = .trial(daysRemaining: daysRemaining)
                        print("✅ Set subscription status to .trial(\(daysRemaining))")
                    } else if subscriptionStatus == "active" {
                        // Parse end date for active subscriptions
                        if let subscriptionEndDateString = userData["subscriptionEndDate"] as? String,
                           let endDate = ISO8601DateFormatter().date(from: subscriptionEndDateString) {
                            self.subscriptionStatus = .active(renewalDate: endDate)
                            print("✅ Active subscription until: \(endDate)")
                        } else {
                            self.subscriptionStatus = .active(renewalDate: Date().addingTimeInterval(86400 * Double(daysRemaining)))
                        }
                    } else {
                        self.subscriptionStatus = .expired
                        print("⚠️ Set subscription status to .expired (status='\(subscriptionStatus)', days=\(daysRemaining))")
                    }
                } else {
                    self.subscriptionStatus = .expired
                    print("❌ Failed to parse user data from backend response")
                }
            } else {
                self.subscriptionStatus = .expired
                print("❌ Failed to parse JSON from backend response")
            }
        } catch {
            print("❌ Error checking trial status: \(error)")
            subscriptionStatus = .expired
        }
    }
    
    // MARK: - Listen for Transactions
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            // Listen for transaction updates
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    
                    print("🔄 Transaction update received: \(transaction.productID)")
                    
                    // Update local subscription status
                    await self.updateSubscriptionStatus(transaction: transaction)
                    
                    // CRITICAL: Validate receipt with backend for all transaction updates
                    await self.validateReceiptWithBackend(transaction: transaction)
                    
                    // Finish the transaction
                    await transaction.finish()
                } catch {
                    print("❌ Transaction update failed: \(error)")
                }
            }
        }
    }
    
    // MARK: - Verify Transaction
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            // StoreKit has parsed the JWS but failed verification
            throw StoreError.failedVerification
        case .verified(let safe):
            // Transaction is verified
            return safe
        }
    }
    
    // MARK: - Sync with Backend
    
    /// Validate Apple receipt with backend (Industry best practice)
    private func validateReceiptWithBackend(transaction: Transaction) async {
        guard let _ = getUserId(), let token = getAuthToken() else { return }
        
        do {
            // Get the receipt from the device
            guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
                  let receiptData = try? Data(contentsOf: appStoreReceiptURL) else {
                print("❌ No receipt found")
                return
            }
            
            let receiptString = receiptData.base64EncodedString()
            
            print("🍎 Sending receipt for validation to backend...")
            
            let url = URL(string: "\(Config.apiBaseURL)/api/subscription/apple/validate-receipt")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: Any] = [
                "receipt": receiptString,
                "transactionId": transaction.id
            ]
            
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("🔍 Receipt validation response status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 {
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let success = json["success"] as? Bool, success {
                        print("✅ Receipt validated by backend")
                        print("   Subscription Status: \(json["subscriptionStatus"] as? String ?? "unknown")")
                        print("   Expires Date: \(json["expiresDate"] as? String ?? "unknown")")
                        print("   Environment: \(json["environment"] as? String ?? "unknown")")
                    } else {
                        print("❌ Backend receipt validation failed")
                    }
                } else {
                    print("❌ Receipt validation failed with status: \(httpResponse.statusCode)")
                    if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let error = errorData["error"] as? String {
                        print("   Error: \(error)")
                    }
                }
            }
        } catch {
            print("❌ Failed to validate receipt with backend: \(error)")
        }
    }
    
    /// Legacy sync method (deprecated - use validateReceiptWithBackend instead)
    private func syncSubscriptionWithBackend(status: String, endDate: Date?) async {
        guard let userId = getUserId(), let token = getAuthToken() else { return }
        
        do {
            let url = URL(string: "\(Config.apiBaseURL)/api/subscription/sync")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: Any] = [
                "userId": userId,
                "subscriptionStatus": status,
                "subscriptionEndDate": endDate?.ISO8601Format() ?? ""
            ]
            
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("✅ Subscription synced with backend")
            }
        } catch {
            print("❌ Failed to sync subscription with backend: \(error)")
        }
    }
    
    // MARK: - Helper Methods
    private func getUserId() -> String? {
        return DataManager.shared.currentUser?.userId
    }
    
    private func getAuthToken() -> String? {
        return DataManager.shared.currentUser?.authToken
    }
    
    // MARK: - Check if User Has Access
    func hasActiveAccess() -> Bool {
        switch subscriptionStatus {
        case .trial, .active, .gracePeriod:
            return true
        case .expired, .unknown:
            return false
        }
    }
    
    // MARK: - Get Days Remaining
    func getDaysRemaining() -> Int? {
        switch subscriptionStatus {
        case .trial(let days), .gracePeriod(let days):
            return days
        case .active(let renewalDate):
            let now = Date()
            return Calendar.current.dateComponents([.day], from: now, to: renewalDate).day
        case .expired, .unknown:
            return nil
        }
    }
}

// MARK: - Store Error
enum StoreError: Error {
    case failedVerification
}

