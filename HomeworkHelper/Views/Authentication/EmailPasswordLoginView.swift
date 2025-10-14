import SwiftUI

struct EmailPasswordLoginView: View {
    @EnvironmentObject var authService: AuthenticationService
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State private var email = ""
    @State private var password = ""
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.blue.opacity(0.6),
                Color.purple.opacity(0.6)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var warningNotice: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.yellow)
                    .font(.title3)
                
                Text("Organization/Test Accounts Only")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .foregroundColor(.white)
            
            Text("This login is for organization or test accounts only. New users should use Sign in with Apple or Google.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.95))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.yellow.opacity(0.5), lineWidth: 2)
                )
        )
        .padding(.horizontal)
        .padding(.top, 40)
    }
    
    private var emailField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Email")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            TextField("Enter your email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
    }
    
    private var passwordField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Password")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            SecureField("Enter your password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    
    private var loginButton: some View {
        Button(action: {
            authService.signInWithEmail(email: email, password: password)
        }) {
            HStack(spacing: 12) {
                if authService.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
                Text("Log In")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isFormValid ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(!isFormValid || authService.isLoading)
    }
    
    private var loginForm: some View {
        VStack(spacing: 20) {
            emailField
            passwordField
            
            // Error Message
            if let errorMessage = authService.errorMessage {
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.white.opacity(0.95))
                    .cornerRadius(8)
                    .multilineTextAlignment(.center)
            }
            
            loginButton
        }
        .padding(.horizontal, 32)
    }
    
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 24) {
                warningNotice
                loginForm
                Spacer()
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                contentView
            }
            .navigationTitle("Organization Login")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.white)
                }
            )
        }
        .onChange(of: authService.isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                dismiss()
            }
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && 
        !password.isEmpty && 
        email.contains("@") &&
        password.count >= 6
    }
}

#Preview {
    EmailPasswordLoginView()
        .environmentObject(AuthenticationService())
}

