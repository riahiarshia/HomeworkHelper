import SwiftUI
import StoreKit

/// Paywall View - Premium subscription screen
/// Follows Apple best practices for subscription presentation
struct PaywallView: View {
    @StateObject private var subscriptionService = SubscriptionService.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedPlan: SubscriptionPlan = .monthly
    @State private var showingTerms = false
    @State private var showingPrivacy = false
    @State private var isPurchasing = false
    
    enum SubscriptionPlan {
        case monthly
    }
    
    var body: some View {
        ZStack {
            // Background gradient (more purple, less pink)
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.4, green: 0.2, blue: 0.8).opacity(0.9), Color(red: 0.2, green: 0.4, blue: 0.9).opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    
                    
                    // Header
                    headerSection
                    
                    // CTA Button (moved to top)
                    ctaButton
                    
                    // Features
                    featuresSection
                    
                    // Pricing Card
                    pricingCard
                    
                    // Subscribe Directly Button
                    subscribeButton
                    
                    // Error Message
                    if let error = subscriptionService.errorMessage {
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    
                    // Restore Purchases
                    restoreButton
                    
                    // Legal Links
                    legalLinks
                }
                .padding()
            }
        }
        .onAppear {
            Task {
                await subscriptionService.loadProducts()
            }
        }
        .sheet(isPresented: $showingTerms) {
            TermsOfUseView()
        }
        .sheet(isPresented: $showingPrivacy) {
            PrivacyPolicyView()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 0) {
            // Icon
            ZStack {
                
            }
            
            Text(isExpired ? "Your Trial Has Ended" : "Ready to Subscribe?")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            
        }
        .padding(.top, 20)
    }
    
    // MARK: - Helper Properties
    private var isExpired: Bool {
        if case .expired = subscriptionService.subscriptionStatus {
            return true
        }
        return false
    }
    
    // MARK: - Features Section
    private var featuresSection: some View {
        VStack(spacing: 20) {
            FeatureRow(
                icon: "checkmark.circle.fill",
                title: "Unlimited Problem Solving",
                description: "No limits on homework questions"
            )
            
            FeatureRow(
                icon: "lightbulb.fill",
                title: "Step-by-Step Guidance",
                description: "Learn with personalized hints"
            )
            
            FeatureRow(
                icon: "graduationcap.fill",
                title: "All Subjects Covered",
                description: "Math, Science, English, and more"
            )
            
            
            FeatureRow(
                icon: "sparkles",
                title: "AI-Powered Tutoring",
                description: "Advanced AI that adapts to your level"
            )
        }
        .padding(.horizontal)
    }
    
    // MARK: - Pricing Card
    private var pricingCard: some View {
        VStack(spacing: 16) {
            // Price
            VStack(spacing: 8) {
                if let product = subscriptionService.currentSubscription {
                    Text(product.displayPrice)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("per month")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                } else {
                    Text("$9.99")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("per month")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            // Subscription Info
            VStack(spacing: 4) {
                Text("Continue your learning journey")
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Text("Cancel anytime in Settings")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
    
    // MARK: - CTA Button
    private var ctaButton: some View {
        VStack(spacing: 12) {
            // Main Subscribe Button
            Button {
                purchaseSubscription()
            } label: {
                HStack {
                    if isPurchasing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                        Text("Processing...")
                            .fontWeight(.bold)
                    } else {
                        Text(isExpired ? "Subscribe Now" : "Start Free Trial")
                            .fontWeight(.bold)
                        Image(systemName: isExpired ? "arrow.right.circle.fill" : "gift.fill")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .foregroundColor(.purple)
                .cornerRadius(16)
            }
            .disabled(isPurchasing || subscriptionService.isLoading)
            
            // Not Now Button (only show for expired users)
            if isExpired {
                Button {
                    dismiss()
                } label: {
                    Text("Not Now")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .underline()
                }
                .disabled(isPurchasing || subscriptionService.isLoading)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Subscribe Directly Button
    private var subscribeButton: some View {
        Button {
            purchaseSubscription()
        } label: {
            Text("Subscribe Now ($9.99/month)")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .underline()
        }
        .disabled(isPurchasing || subscriptionService.isLoading)
        .padding(.top, 8)
    }
    
    // MARK: - Restore Button
    private var restoreButton: some View {
        Button {
            restorePurchases()
        } label: {
            Text("Restore Purchases")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .underline()
        }
        .disabled(isPurchasing || subscriptionService.isLoading)
    }
    
    // MARK: - Legal Links
    private var legalLinks: some View {
        VStack(spacing: 12) {
            Text("Subscription automatically renews unless cancelled at least 24 hours before the end of the current period.")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
            
            HStack(spacing: 20) {
                Button("Terms of Use") {
                    showingTerms = true
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                
                Button("Privacy Policy") {
                    showingPrivacy = true
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
    
    // MARK: - Actions
    private func purchaseSubscription() {
        print("🛒 Purchase button tapped")
        isPurchasing = true
        
        // ALWAYS use real StoreKit flow (works with sandbox and production)
        // Sandbox testing requires the actual purchase flow
        Task {
            print("🛒 Starting purchase flow...")
            print("🛒 Environment: \(isSandbox ? "Sandbox" : "Production")")
            
            let success = await subscriptionService.purchase()
            isPurchasing = false
            
            print("🛒 Purchase result: \(success)")
            
            if success {
                print("✅ Purchase successful, dismissing paywall")
                // Dismiss paywall on successful purchase
                dismiss()
            } else {
                print("❌ Purchase failed or cancelled")
            }
        }
    }
    
    // Helper to detect sandbox environment
    private var isSandbox: Bool {
        #if DEBUG
        return true
        #else
        return Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
        #endif
    }
    
    private func restorePurchases() {
        isPurchasing = true
        
        Task {
            await subscriptionService.restorePurchases()
            isPurchasing = false
            
            // Check if subscription is now active
            if subscriptionService.hasActiveAccess() {
                dismiss()
            }
        }
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }
}

// MARK: - Preview
struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView()
    }
}

