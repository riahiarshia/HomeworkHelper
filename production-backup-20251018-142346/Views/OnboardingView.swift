import SwiftUI
import AuthenticationServices
import CryptoKit

struct OnboardingView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var showEmailLogin = false
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var isSignUp = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Spacer()
                
                // Top Section - Smiley Face
                VStack(spacing: 20) {
                    // Custom logo
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 240, height: 240)
                    
                    // Title and Subtitle
                    VStack(spacing: 8) {
                        Text("Ai Homework Helper")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text("No cheating, Real Learning")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Text("Your AI Tutor for step by step learning")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                    }
                }
                
                Spacer()
                
                // Authentication Section
                if showEmailLogin {
                    // Email/Password Login Form
                    VStack(spacing: 20) {
                        Text(isSignUp ? "Create Account" : "Sign In")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        if isSignUp {
                            TextField("Username", text: $username)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        // Error message
                        if let errorMessage = authService.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Login/Signup button
                        Button(action: {
                            if isSignUp {
                                authService.signUpWithEmail(email: email, password: password, username: username)
                            } else {
                                authService.signInWithEmail(email: email, password: password)
                            }
                        }) {
                            HStack {
                                if authService.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                Text(isSignUp ? "Create Account" : "Sign In")
                                    .font(.headline)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        .disabled(authService.isLoading || email.isEmpty || password.isEmpty || (isSignUp && username.isEmpty))
                        
                        // Toggle between sign in and sign up
                        Button(action: {
                            isSignUp.toggle()
                            authService.errorMessage = nil
                        }) {
                            Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        
                        // Back to main options
                        Button(action: {
                            showEmailLogin = false
                            email = ""
                            password = ""
                            username = ""
                            isSignUp = false
                            authService.errorMessage = nil
                        }) {
                            Text("Back to login options")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 32)
                } else {
                    // Main Authentication Buttons
                    VStack(spacing: 16) {
                        // Sign in with Apple
                        SignInWithAppleButton(
                            onRequest: { request in
                                request.requestedScopes = [.fullName, .email]
                            },
                            onCompletion: { result in
                                authService.handleAppleSignIn(result: result)
                            }
                        )
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 56)
                        .cornerRadius(12)
                        .disabled(authService.isLoading)
                        
                        // Sign in with Google
                        Button(action: {
                            authService.signInWithGoogle()
                        }) {
                            HStack {
                                Image(systemName: "globe")
                                    .font(.title2)
                                Text("Sign in with Google")
                                    .font(.headline)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .cornerRadius(12)
                        }
                        .disabled(authService.isLoading)
                        
                        // Email/Password login option
                        Button(action: {
                            showEmailLogin = true
                        }) {
                            HStack {
                                Image(systemName: "envelope")
                                    .font(.title2)
                                Text("Sign in with Email")
                                    .font(.headline)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .cornerRadius(12)
                        }
                        .disabled(authService.isLoading)
                    }
                    .padding(.horizontal, 32)
                }
                
                // Subscription banner
                VStack(spacing: 8) {
                    Text("7-Day Free Trial Available")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                    
                    Text("Then $9.99/month • Cancel anytime")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("New subscribers only")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Loading indicator
                if authService.isLoading {
                    ProgressView()
                        .scaleEffect(1.2)
                        .padding()
                }
            }
            .padding()
            .navigationBarHidden(true)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.1),
                        Color.purple.opacity(0.1),
                        Color(.systemBackground)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }
    
}

#Preview {
    OnboardingView()
        .environmentObject(AuthenticationService())
}
