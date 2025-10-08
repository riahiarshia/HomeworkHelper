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
    
    // MARK: - Transaction Listener
    private var updateListenerTask: Task<Void, Error>?
    
    // MARK: - Initialization
    private init() {
        // Start listening for transaction updates
        updateListenerTask = listenForTransactions()
        
        // Load initial subscription status
        Task {
            await loadSubscriptionStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Load Products
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Request products from App Store
            let products = try await Product.products(for: [monthlySubscriptionID])
            
            if products.isEmpty {
                errorMessage = "No subscription products available. Please check your App Store Connect configuration."
                print("⚠️ No products found for ID: \(monthlySubscriptionID)")
            } else {
                currentSubscription = products.first
                print("✅ Loaded subscription product: \(products.first?.displayName ?? "Unknown")")
                print("   Price: \(products.first?.displayPrice ?? "Unknown")")
                print("   Description: \(products.first?.description ?? "Unknown")")
            }
        } catch {
            errorMessage = "Failed to load subscription: \(error.localizedDescription)"
            print("❌ Error loading products: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Purchase Subscription
    func purchase() async -> Bool {
        guard let product = currentSubscription else {
            errorMessage = "No subscription product available"
            return false
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Attempt purchase
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // Check transaction verification
                let transaction = try checkVerified(verification)
                
                // Update subscription status
                await updateSubscriptionStatus(transaction: transaction)
                
                // Finish the transaction
                await transaction.finish()
                
                print("✅ Purchase successful!")
                isLoading = false
                return true
                
            case .userCancelled:
                print("ℹ️ User cancelled purchase")
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
            
            // Reload subscription status
            await loadSubscriptionStatus()
            
            print("✅ Purchases restored")
        } catch {
            errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
            print("❌ Restore error: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Load Subscription Status
    func loadSubscriptionStatus() async {
        // Check for active subscriptions
        var activeSubscription: Transaction?
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                // Check if this is our subscription product
                if transaction.productID == monthlySubscriptionID {
                    activeSubscription = transaction
                    break
                }
            } catch {
                print("❌ Transaction verification failed: \(error)")
            }
        }
        
        if let transaction = activeSubscription {
            await updateSubscriptionStatus(transaction: transaction)
        } else {
            // No active subscription - check trial status
            await checkTrialStatus()
        }
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
        // Get trial info from backend
        guard let userId = getUserId(), let token = getAuthToken() else {
            subscriptionStatus = .expired
            return
        }
        
        do {
            let url = URL(string: "https://homework-helper-api.azurewebsites.net/api/auth/validate-session")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let (data, _) = try await URLSession.shared.data(for: request)
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let subscriptionStatus = json["subscription_status"] as? String,
               let subscriptionEndDateString = json["subscription_end_date"] as? String {
                
                let dateFormatter = ISO8601DateFormatter()
                if let endDate = dateFormatter.date(from: subscriptionEndDateString) {
                    let now = Date()
                    let daysRemaining = Calendar.current.dateComponents([.day], from: now, to: endDate).day ?? 0
                    
                    if subscriptionStatus == "trial" && daysRemaining > 0 {
                        self.subscriptionStatus = .trial(daysRemaining: daysRemaining)
                        print("✅ Trial active: \(daysRemaining) days remaining")
                    } else {
                        self.subscriptionStatus = .expired
                        print("⚠️ Trial expired")
                    }
                } else {
                    self.subscriptionStatus = .expired
                }
            } else {
                self.subscriptionStatus = .expired
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
                    
                    // Update subscription status
                    await self.updateSubscriptionStatus(transaction: transaction)
                    
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
    private func syncSubscriptionWithBackend(status: String, endDate: Date?) async {
        guard let userId = getUserId(), let token = getAuthToken() else { return }
        
        do {
            let url = URL(string: "https://homework-helper-api.azurewebsites.net/api/subscription/sync")!
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

