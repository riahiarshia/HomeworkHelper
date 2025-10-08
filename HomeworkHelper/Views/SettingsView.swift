import SwiftUI
import MessageUI

struct SettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var authService: AuthenticationService
    @State private var apiKey: String = ""
    @State private var azureClientSecret: String = ""
    @State private var showingAPIKeyAlert = false
    @State private var showingResetAlert = false
    @State private var showingAzureSecretAlert = false
    @State private var isRefreshingAzure = false
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfUse = false
    @State private var showingDisclaimer = false
    @State private var emailCopied = false
    @State private var showingSignOutAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                // Backend API Section
                Section(header: Text("Backend API")) {
                    HStack {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundColor(.green)
                        Text("Backend API Configured")
                            .font(.headline)
                    }
                    
                    Text("All AI requests are processed securely through our backend server. No API keys are stored on your device.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if false {
                    Section(header: Text("Azure Key Vault")) {
                        HStack {
                            Image(systemName: "checkmark.shield.fill")
                                .foregroundColor(.green)
                            Text("Azure Key Vault Configured")
                                .font(.headline)
                        }
                        
                        Text("Azure integration is now handled by the backend server.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("API key is automatically fetched from Azure Key Vault. Updates refresh every hour.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Section(header: Text("Azure Client Secret")) {
                        SecureField("Client Secret (optional update)", text: $azureClientSecret)
                            .textContentType(.password)
                            .autocapitalization(.none)
                        
                        Button("Update Client Secret") {
                            AzureKeyVaultService.shared.setClientSecret(azureClientSecret)
                            azureClientSecret = ""
                            showingAzureSecretAlert = true
                        }
                        .disabled(azureClientSecret.isEmpty)
                        
                        Text("Only update this if you've rotated your Azure client secret.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Legacy Configuration (Disabled)")) {
                    if false {
                        Text("✅ Using Azure Key Vault for API key management")
                            .font(.caption)
                            .foregroundColor(.green)
                        
                        Text("Manual entry below is for emergency use only")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("API key management is now handled by the backend server.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Account")) {
                    if let user = dataManager.currentUser {
                        // Email
                        if let email = user.email {
                            HStack {
                                Text("Email")
                                Spacer()
                                Text(email)
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
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
                            showingSignOutAlert = true
                        }) {
                            HStack {
                                Image(systemName: "arrow.right.square")
                                    .foregroundColor(.red)
                                Text("Sign Out")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                
                Section(header: Text("Data")) {
                    Button("Reset All Data") {
                        showingResetAlert = true
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
                            UIPasteboard.general.string = "homework@arshia.com"
                            emailCopied = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                emailCopied = false
                            }
                        } label: {
                            HStack {
                                Text("homework@arshia.com")
                                    .foregroundColor(.blue)
                                    .underline()
                                Spacer()
                                if emailCopied {
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
            .navigationTitle("Settings")
            .alert("API Key Saved", isPresented: $showingAPIKeyAlert) {
                Button("OK") { }
            } message: {
                Text("Your OpenAI API key has been saved successfully.")
            }
            .alert("Azure Client Secret Updated", isPresented: $showingAzureSecretAlert) {
                Button("OK") { }
            } message: {
                Text("Your Azure client secret has been updated. The API key will be refreshed on next app launch.")
            }
            .alert("Reset All Data?", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("This will permanently delete all your homework problems, progress, and chat history. This action cannot be undone.")
            }
            .alert("Sign Out?", isPresented: $showingSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    authService.signOut()
                    dataManager.currentUser = nil
                }
            } message: {
                Text("Are you sure you want to sign out? Your data will be saved.")
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
        }
    }
    
    private func resetAllData() {
        dataManager.problems = []
        dataManager.steps = [:]
        dataManager.messages = [:]
        dataManager.progress = []
        dataManager.currentUser = User(username: "Student", age: nil, grade: nil, points: 0, streak: 0)
        dataManager.saveData()
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
