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
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    headerSection
                    
                    // Features
                    featuresSection
                    
                    // Pricing Card
                    pricingCard
                    
                    // CTA Button
                    ctaButton
                    
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
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
            
            Text("Unlock Your Full Potential")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("Get unlimited access to your AI tutor")
                .font(.title3)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
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
                icon: "chart.line.uptrend.xyaxis",
                title: "Track Your Progress",
                description: "See your improvement over time"
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
            // Trial Badge
            HStack {
                Spacer()
                Text("🎉 7-DAY FREE TRIAL")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.white)
                    )
                Spacer()
            }
            
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
            
            // Trial Info
            VStack(spacing: 4) {
                Text("Start your 7-day free trial")
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Text("Cancel anytime")
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
                    Text("Start Free Trial")
                        .fontWeight(.bold)
                    Image(systemName: "arrow.right")
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .foregroundColor(.purple)
            .cornerRadius(16)
        }
        .disabled(isPurchasing || subscriptionService.isLoading)
        .padding(.horizontal)
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
        isPurchasing = true
        
        Task {
            let success = await subscriptionService.purchase()
            isPurchasing = false
            
            if success {
                // Dismiss paywall on successful purchase
                dismiss()
            }
        }
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

