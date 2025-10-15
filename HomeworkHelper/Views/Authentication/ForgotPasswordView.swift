import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject var authService: AuthenticationService
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State private var email = ""
    @State private var isRequesting = false
    @State private var showSuccess = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                            .padding(.top, 40)
                        
                        Text("Forgot Password?")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Enter your email address and we'll send you a link to reset your password.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    if showSuccess {
                        successMessage
                    } else {
                        requestForm
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Reset Password")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
            )
        }
    }
    
    private var requestForm: some View {
        VStack(spacing: 20) {
            // Email Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Email Address")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField("Enter your email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            
            // Error Message
            if let error = errorMessage {
                Text(error)
                    .font(.subheadline)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                    .multilineTextAlignment(.center)
            }
            
            // Send Reset Link Button
            Button(action: {
                requestPasswordReset()
            }) {
                HStack(spacing: 12) {
                    if isRequesting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    Text("Send Reset Link")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isEmailValid ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(!isEmailValid || isRequesting)
        }
        .padding(.horizontal)
    }
    
    private var successMessage: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Check Your Email")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("If an account exists with \(email), you will receive a password reset link shortly.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Back to Login") {
                dismiss()
            }
            .font(.headline)
            .foregroundColor(.blue)
            .padding(.top, 20)
        }
        .padding()
    }
    
    private var isEmailValid: Bool {
        !email.isEmpty && email.contains("@")
    }
    
    private func requestPasswordReset() {
        guard isEmailValid else { return }
        
        isRequesting = true
        errorMessage = nil
        
        Task {
            let success = await requestReset(email: email)
            
            await MainActor.run {
                isRequesting = false
                if success {
                    showSuccess = true
                }
            }
        }
    }
    
    private func requestReset(email: String) async -> Bool {
        let backendURL = Config.apiBaseURL
        
        guard let url = URL(string: "\(backendURL)/api/auth/request-reset") else {
            await MainActor.run {
                self.errorMessage = "Invalid backend URL"
            }
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["email": email.lowercased()]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else {
            await MainActor.run {
                self.errorMessage = "Failed to encode request"
            }
            return false
        }
        
        request.httpBody = httpBody
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                await MainActor.run {
                    self.errorMessage = "Invalid response from server"
                }
                return false
            }
            
            if httpResponse.statusCode == 200 {
                // Always return success to prevent email enumeration
                return true
            } else {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let error = json["error"] as? String {
                    await MainActor.run {
                        self.errorMessage = error
                    }
                } else {
                    await MainActor.run {
                        self.errorMessage = "Failed to send reset email. Please try again."
                    }
                }
                return false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Network error: \(error.localizedDescription)"
            }
            return false
        }
    }
}

#Preview {
    ForgotPasswordView()
        .environmentObject(AuthenticationService())
}

