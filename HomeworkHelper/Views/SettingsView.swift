import SwiftUI
import MessageUI

enum SettingsAlert: Identifiable {
    case clearHistory
    case signOut
    case deleteAccount
    
    var id: String {
        switch self {
        case .clearHistory: return "clearHistory"
        case .signOut: return "signOut"
        case .deleteAccount: return "deleteAccount"
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var subscriptionService: SubscriptionService
    @State private var activeAlert: SettingsAlert?
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfUse = false
    @State private var showingDisclaimer = false
    @State private var emailCopied = false
    @State private var userIdCopied = false
    @State private var supportEmailCopied = false
    @State private var isDeletingAccount = false
    @State private var showPaywall = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient (more purple, less pink)
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.4, green: 0.2, blue: 0.8).opacity(0.9), Color(red: 0.2, green: 0.4, blue: 0.9).opacity(0.7)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                Form {
                // Subscription Section
                Section(header: Text("Subscription")) {
                    switch subscriptionService.subscriptionStatus {
                    case .trial(let daysRemaining):
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "gift.fill")
                                    .foregroundColor(.green)
                                Text("Trial Active")
                                    .font(.headline)
                                Spacer()
                                Text("\(daysRemaining) day\(daysRemaining == 1 ? "" : "s") left")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text("Enjoy full access to your AI tutor")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Button {
                                showPaywall = true
                            } label: {
                                HStack {
                                    Text("Upgrade to Premium")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Image(systemName: "arrow.right")
                                }
                            }
                        }
                        
                    case .active(let renewalDate):
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.green)
                                Text("Premium Active")
                                    .font(.headline)
                            }
                            
                            Text("Renews on \(renewalDate, style: .date)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Button {
                                if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                HStack {
                                    Text("Manage Subscription")
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square")
                                }
                            }
                        }
                        
                    case .expired:
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.red)
                                Text("Subscription Expired")
                                    .font(.headline)
                            }
                            
                            Button {
                                showPaywall = true
                            } label: {
                                HStack {
                                    Text("Renew Subscription")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Image(systemName: "arrow.right")
                                }
                            }
                        }
                        
                    case .gracePeriod(let daysRemaining):
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("Payment Issue")
                                    .font(.headline)
                            }
                            
                            Text("\(daysRemaining) day\(daysRemaining == 1 ? "" : "s") of access remaining")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Button {
                                if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                HStack {
                                    Text("Update Payment Method")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square")
                                }
                            }
                        }
                        
                    case .unknown:
                        HStack {
                            ProgressView()
                            Text("Loading subscription status...")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button {
                        Task {
                            await subscriptionService.restorePurchases()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Restore Purchases")
                        }
                    }
                    .disabled(subscriptionService.isLoading)
                }
                
                Section(header: Text("Account")) {
                    if let user = dataManager.currentUser {
                        // Email
                        if let email = user.email {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("Email")
                                    Spacer()
                                    Button(action: {
                                        UIPasteboard.general.string = email
                                        emailCopied = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            emailCopied = false
                                        }
                                    }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: emailCopied ? "checkmark" : "doc.on.doc")
                                                .font(.caption)
                                            Text(emailCopied ? "Copied!" : "Copy")
                                                .font(.caption)
                                        }
                                        .foregroundColor(.blue)
                                    }
                                }
                                Text(email)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }
                        }
                        
                        // User ID (for support) - PRIMARY SUPPORT IDENTIFIER
                        if let userId = user.userId {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("User ID")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Button(action: {
                                        UIPasteboard.general.string = userId
                                        userIdCopied = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            userIdCopied = false
                                        }
                                    }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: userIdCopied ? "checkmark" : "doc.on.doc")
                                                .font(.caption)
                                            Text(userIdCopied ? "Copied!" : "Copy")
                                                .font(.caption)
                                        }
                                        .foregroundColor(.blue)
                                    }
                                }
                                Text(userId)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }
                            
                            Text("📋 Copy this ID when contacting support")
                                .font(.caption2)
                                .foregroundColor(.blue)
                                .fontWeight(.medium)
                                .padding(.top, 4)
                        }
                        
                        // Subscription Status
                        if let status = user.subscriptionStatus {
                            HStack {
                                Text("Subscription")
                                Spacer()
                                HStack(spacing: 4) {
                                    if status == "trial" {
                                        Image(systemName: "clock.fill")
                                            .foregroundColor(.orange)
                                            .font(.caption)
                                    } else if status == "active" {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .font(.caption)
                                    } else {
                                        Image(systemName: "exclamationmark.circle.fill")
                                            .foregroundColor(.red)
                                            .font(.caption)
                                    }
                                    Text(status.capitalized)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            // Days remaining
                            if let days = user.daysRemaining {
                                HStack {
                                    Text("Days Remaining")
                                    Spacer()
                                    Text("\(days) days")
                                        .foregroundColor(days <= 3 ? .red : .secondary)
                                }
                            }
                        }
                        
                        NavigationLink(destination: EditProfileView()) {
                            HStack {
                                Text("Profile")
                                Spacer()
                                Text(user.username)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack {
                            Text("Grade Level")
                            Spacer()
                            Text(user.getGradeLevel())
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Total Points")
                            Spacer()
                            Text("\(user.points)")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Streak")
                            Spacer()
                            Text("\(user.streak) days")
                                .foregroundColor(.secondary)
                        }
                        
                        // Sign Out Button
                        Button(action: {
                            activeAlert = .signOut
                        }) {
                            HStack {
                                Image(systemName: "arrow.right.square")
                                    .foregroundColor(.orange)
                                Text("Sign Out")
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        // Delete Account Button
                        Button(action: {
                            print("🗑️ Delete Account button tapped")
                            activeAlert = .deleteAccount
                        }) {
                            HStack {
                                Image(systemName: "trash.fill")
                                    .foregroundColor(.red)
                                Text("Delete Account")
                                    .foregroundColor(.red)
                            }
                        }
                        .disabled(isDeletingAccount)
                    }
                }
                
                Section(header: Text("Data")) {
                    Button("Clear Homework History") {
                        activeAlert = .clearHistory
                    }
                    .foregroundColor(.red)
                }
                
                Section(header: Text("Support & Legal")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.blue)
                            Text("Contact Us")
                                .font(.headline)
                        }
                        
                        Button {
                            UIPasteboard.general.string = "support_homewor@arshia.com"
                            supportEmailCopied = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                supportEmailCopied = false
                            }
                        } label: {
                            HStack {
                                Text("support_homework@arshia.com")
                                    .foregroundColor(.blue)
                                    .underline()
                                Spacer()
                                if supportEmailCopied {
                                    HStack(spacing: 4) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        Text("Copied!")
                                            .foregroundColor(.green)
                                            .font(.caption)
                                    }
                                } else {
                                    Image(systemName: "doc.on.doc")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        
                        Text("Tap to copy email address")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Button {
                        showingDisclaimer = true
                    } label: {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("Important Disclaimer")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button {
                        showingPrivacyPolicy = true
                    } label: {
                        HStack {
                            Image(systemName: "lock.shield.fill")
                                .foregroundColor(.green)
                            Text("Privacy Policy")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button {
                        showingTermsOfUse = true
                    } label: {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.purple)
                            Text("Terms of Use")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .alert(item: $activeAlert) { alertType in
                switch alertType {
                case .clearHistory:
                    return Alert(
                        title: Text("Clear Homework History?"),
                        message: Text("This will permanently delete all your homework problems, progress, and chat history. Your account and subscription will remain active."),
                        primaryButton: .cancel(),
                        secondaryButton: .destructive(Text("Clear")) {
                            clearHomeworkHistory()
                        }
                    )
                case .signOut:
                    return Alert(
                        title: Text("Sign Out?"),
                        message: Text("Are you sure you want to sign out? Your homework data will be saved and restored when you sign back in."),
                        primaryButton: .cancel(),
                        secondaryButton: .destructive(Text("Sign Out")) {
                            authService.signOut()
                            dataManager.clearCurrentUser()
                        }
                    )
                case .deleteAccount:
                    return Alert(
                        title: Text("Delete Account?"),
                        message: Text("⚠️ This will permanently delete your account, subscription, and ALL data including homework history. This action cannot be undone!"),
                        primaryButton: .cancel {
                            print("🗑️ Delete cancelled")
                        },
                        secondaryButton: .destructive(Text("Delete Permanently")) {
                            print("🗑️ Delete Permanently button tapped")
                            performAccountDeletion()
                        }
                    )
                }
            }
            .sheet(isPresented: $showingDisclaimer) {
                DisclaimerView()
            }
            .sheet(isPresented: $showingPrivacyPolicy) {
                PrivacyPolicyView()
            }
            .sheet(isPresented: $showingTermsOfUse) {
                TermsOfUseView()
            }
            .onAppear {
                // Refresh subscription status when settings view appears
                Task {
                    print("⚙️ SettingsView - Refreshing subscription status")
                    await subscriptionService.refreshSubscriptionStatus()
                    print("⚙️ SettingsView - Subscription status: \(subscriptionService.subscriptionStatus)")
                }
            }
        }
    }
    
    private func clearHomeworkHistory() {
        // Clear homework data but preserve user authentication
        dataManager.clearHomeworkData()
        
        // Optionally reset points and streak
        if var user = dataManager.currentUser {
            user.points = 0
            user.streak = 0
            dataManager.currentUser = user
        }
    }
    
    private func sendSupportEmail() {
        guard let user = dataManager.currentUser else { return }
        
        // Compose email with user information
        var emailBody = "Please describe your issue:\n\n\n\n"
        emailBody += "--- Account Information (Do Not Delete) ---\n"
        emailBody += "User ID: \(user.userId ?? "N/A")\n"
        emailBody += "Email: \(user.email ?? "N/A")\n"
        emailBody += "Username: \(user.username)\n"
        emailBody += "Subscription: \(user.subscriptionStatus ?? "N/A")\n"
        emailBody += "-------------------------------------------\n"
        
        let encoded = emailBody.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let url = URL(string: "mailto:support_homework@arshia.com?subject=Support%20Request&body=\(encoded)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func performAccountDeletion() {
        print("🗑️ performAccountDeletion() called")
        isDeletingAccount = true
        
        Task {
            print("🗑️ Inside Task - calling authService.deleteAccount()")
            let success = await authService.deleteAccount()
            
            await MainActor.run {
                isDeletingAccount = false
                
                if success {
                    print("✅ Account deleted successfully")
                    // User should be signed out automatically by deleteAccount()
                } else {
                    print("❌ Failed to delete account")
                    if let error = authService.errorMessage {
                        print("❌ Error: \(error)")
                    }
                }
            }
        }
    }
    
}

// MARK: - Disclaimer View
struct DisclaimerView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Important Disclaimer")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom)
                    
                    Group {
                        Text("Educational Tool Only")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        Text("This app is designed as an educational assistance tool to help students learn and understand homework concepts. It is not intended to provide definitive answers or replace proper learning.")
                        
                        Text("Accuracy of Information")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        Text("While we strive for accuracy, we cannot guarantee that all answers, explanations, or guidance provided by this app are correct. AI-generated content may contain errors, and image recognition may misinterpret homework problems.")
                        
                        Text("No Liability")
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        Text("We are not responsible for:")
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("• Incorrect answers or explanations")
                            Text("• Academic consequences from using this app")
                            Text("• Misunderstood homework problems")
                            Text("• Any educational or academic outcomes")
                        }
                        .padding(.leading)
                        
                        Text("Student Responsibility")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Text("Students should:")
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("• Always verify answers independently")
                            Text("• Use this app as a learning aid, not a solution provider")
                            Text("• Consult teachers or tutors for important assignments")
                            Text("• Take responsibility for their own learning")
                        }
                        .padding(.leading)
                        
                        Text("By using this app, you acknowledge and accept these limitations and agree that your education is ultimately your responsibility.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding(.top)
                    }
                }
                .padding()
            }
            .navigationTitle("Disclaimer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Privacy Policy View
struct PrivacyPolicyView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Privacy Policy")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom)
                    
                    Text("Last updated: \(Date().formatted(date: .long, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom)
                    
                    Group {
                        Text("Information We Collect")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Text("We collect the following information:")
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("• Homework images you upload")
                            Text("• Your interactions with the app")
                            Text("• Usage statistics and app performance data")
                            Text("• Contact information when you reach out to us")
                        }
                        .padding(.leading)
                        
                        Text("How We Use Your Information")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Text("Your information is used to:")
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("• Provide homework assistance and guidance")
                            Text("• Improve our AI algorithms and app functionality")
                            Text("• Respond to your support requests")
                            Text("• Analyze usage patterns to enhance user experience")
                        }
                        .padding(.leading)
                        
                        Text("Data Security")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        Text("We implement appropriate security measures to protect your personal information. Your homework images and data are processed securely and are not shared with third parties except as necessary to provide our services.")
                        
                        Text("Data Retention")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        Text("We retain your data only as long as necessary to provide our services. You can delete your data at any time through the app settings.")
                        
                        Text("Your Rights")
                            .font(.headline)
                            .foregroundColor(.purple)
                        
                        Text("You have the right to:")
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("• Access your personal data")
                            Text("• Correct inaccurate data")
                            Text("• Delete your data")
                            Text("• Withdraw consent for data processing")
                        }
                        .padding(.leading)
                        
                        Text("Contact Us")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Text("If you have questions about this Privacy Policy, please contact us through the app's Contact Us feature.")
                    }
                }
                .padding()
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Terms of Use View
struct TermsOfUseView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Terms of Use")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom)
                    
                    Text("Last updated: \(Date().formatted(date: .long, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom)
                    
                    Group {
                        Text("Acceptance of Terms")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Text("By using this app, you agree to these Terms of Use. If you do not agree, please do not use the app.")
                        
                        Text("Educational Use Only")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        Text("This app is intended solely for educational purposes to assist students in learning and understanding homework concepts. It should not be used to cheat or circumvent academic integrity policies.")
                        
                        Text("User Responsibilities")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        Text("Users must:")
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("• Use the app ethically and responsibly")
                            Text("• Verify all answers and explanations independently")
                            Text("• Respect academic integrity policies")
                            Text("• Not share inappropriate content")
                            Text("• Not attempt to reverse engineer or misuse the app")
                        }
                        .padding(.leading)
                        
                        Text("Prohibited Uses")
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        Text("You may not:")
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("• Use the app to cheat on exams or assignments")
                            Text("• Upload inappropriate or harmful content")
                            Text("• Attempt to hack or compromise the app")
                            Text("• Use the app for commercial purposes")
                            Text("• Violate any applicable laws or regulations")
                        }
                        .padding(.leading)
                        
                        Text("Limitation of Liability")
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        Text("We are not liable for any damages arising from your use of this app, including but not limited to academic consequences, incorrect answers, or technical issues.")
                        
                        Text("Modifications")
                            .font(.headline)
                            .foregroundColor(.purple)
                        
                        Text("We reserve the right to modify these terms at any time. Continued use of the app constitutes acceptance of modified terms.")
                        
                        Text("Termination")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        Text("We may terminate or suspend your access to the app at any time for violation of these terms or for any other reason.")
                    }
                }
                .padding()
            }
            .navigationTitle("Terms of Use")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}




// MARK: - Preview
#Preview {
    SettingsView()
        .environmentObject(DataManager.shared)
        .environmentObject(SubscriptionService.shared)
}
