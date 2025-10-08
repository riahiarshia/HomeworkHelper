import SwiftUI
import AuthenticationServices

struct AuthenticationView: View {
    @EnvironmentObject var authService: AuthenticationService
    @Environment(\.colorScheme) var colorScheme
    @State private var showEmailSignIn = false
    @State private var showSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var username = ""
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.6),
                    Color.purple.opacity(0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // App Logo and Title
                VStack(spacing: 16) {
                    Image(systemName: "book.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                    
                    Text("Homework Helper")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Get step-by-step guidance for your homework")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                // Sign In Section
                VStack(spacing: 20) {
                    Text("Choose your sign-in method")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    // Apple Sign In Button
                    SignInWithAppleButton(
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            authService.handleAppleSignIn(result: result)
                        }
                    )
                    .signInWithAppleButtonStyle(.white)
                    .frame(height: 50)
                    .disabled(authService.isLoading)
                    
                    // OR divider
                    HStack {
                        Rectangle()
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 1)
                        Text("OR")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.caption)
                            .padding(.horizontal, 8)
                        Rectangle()
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.vertical, 8)
                    
                    // Google Sign In Button
                    Button(action: {
                        authService.signInWithGoogle()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "globe")
                                .font(.title3)
                            
                            Text("Continue with Google")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                    }
                    .disabled(authService.isLoading)
                    
                    // OR divider
                    HStack {
                        Rectangle()
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 1)
                        Text("OR")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.caption)
                            .padding(.horizontal, 8)
                        Rectangle()
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.vertical, 8)
                    
                    // Email/Password Sign In Button
                    Button(action: {
                        showEmailSignIn = true
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "envelope.fill")
                                .font(.title3)
                            
                            Text("Continue with Email")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                    }
                    .disabled(authService.isLoading)
                    
                    // Loading indicator
                    if authService.isLoading {
                        HStack(spacing: 12) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            Text("Signing in...")
                                .foregroundColor(.white)
                        }
                        .padding()
                    }
                    
                    // Error message
                    if let error = authService.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(8)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Trial info
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("14-day free trial")
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    
                    Text("No credit card required")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.bottom, 40)
            }
        }
        .onChange(of: authService.isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                // Authentication successful, handled by parent view
                print("✅ User authenticated in view")
                showEmailSignIn = false
                showSignUp = false
            }
        }
        .sheet(isPresented: $showEmailSignIn) {
            EmailSignInView(isPresented: $showEmailSignIn, showSignUp: $showSignUp)
                .environmentObject(authService)
        }
        .sheet(isPresented: $showSignUp) {
            EmailSignUpView(isPresented: $showSignUp)
                .environmentObject(authService)
        }
    }
}

// MARK: - Email Sign In View
struct EmailSignInView: View {
    @EnvironmentObject var authService: AuthenticationService
    @Binding var isPresented: Bool
    @Binding var showSignUp: Bool
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "envelope.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                            
                            Text("Sign In with Email")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        .padding(.top, 40)
                        
                        // Form
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                TextField("your@email.com", text: $email)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .textContentType(.emailAddress)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                SecureField("Enter your password", text: $password)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .textContentType(.password)
                            }
                            
                            Button(action: {
                                authService.signInWithEmail(email: email, password: password)
                            }) {
                                Text("Sign In")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(isValidInput ? Color.blue : Color.gray)
                                    .cornerRadius(12)
                            }
                            .disabled(!isValidInput || authService.isLoading)
                            
                            if authService.isLoading {
                                ProgressView()
                                    .padding()
                            }
                            
                            if let error = authService.errorMessage {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding()
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(8)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.horizontal, 32)
                        
                        // Sign up link
                        Button(action: {
                            isPresented = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                showSignUp = true
                            }
                        }) {
                            HStack(spacing: 4) {
                                Text("Don't have an account?")
                                    .foregroundColor(.secondary)
                                Text("Sign Up")
                                    .foregroundColor(.blue)
                                    .fontWeight(.semibold)
                            }
                            .font(.subheadline)
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private var isValidInput: Bool {
        !email.isEmpty && email.contains("@") && password.count >= 6
    }
}

// MARK: - Email Sign Up View
struct EmailSignUpView: View {
    @EnvironmentObject var authService: AuthenticationService
    @Binding var isPresented: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var username = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "person.crop.circle.fill.badge.plus")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                            
                            Text("Create Account")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        .padding(.top, 40)
                        
                        // Form
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Full Name")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                TextField("Enter your full name", text: $username)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .textContentType(.name)
                                    .autocapitalization(.words)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                TextField("your@email.com", text: $email)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .textContentType(.emailAddress)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                SecureField("At least 6 characters", text: $password)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .textContentType(.newPassword)
                                
                                Text("Minimum 6 characters")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Confirm Password")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                SecureField("Re-enter password", text: $confirmPassword)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .textContentType(.newPassword)
                                
                                if !confirmPassword.isEmpty && password != confirmPassword {
                                    Text("Passwords don't match")
                                        .font(.caption2)
                                        .foregroundColor(.red)
                                }
                            }
                            
                            Button(action: {
                                authService.signUpWithEmail(email: email, password: password, username: username)
                            }) {
                                Text("Create Account")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(isValidInput ? Color.blue : Color.gray)
                                    .cornerRadius(12)
                            }
                            .disabled(!isValidInput || authService.isLoading)
                            
                            if authService.isLoading {
                                ProgressView()
                                    .padding()
                            }
                            
                            if let error = authService.errorMessage {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding()
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(8)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.horizontal, 32)
                        
                        // Terms
                        Text("By creating an account, you agree to our Terms of Service and Privacy Policy")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private var isValidInput: Bool {
        !username.isEmpty && 
        username.count >= 2 &&
        !email.isEmpty && 
        email.contains("@") && 
        password.count >= 6 && 
        password == confirmPassword
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(AuthenticationService())
}

