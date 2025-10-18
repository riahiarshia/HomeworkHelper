import SwiftUI
import AuthenticationServices

struct AuthenticationView: View {
    @EnvironmentObject var authService: AuthenticationService
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
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
                    
                    Text("Your AI Tutor for Step-by-Step Learning")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.95))
                        .multilineTextAlignment(.center)
                    
                    Text("No Cheating - Real Learning")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Prominent Trial CTA
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "gift.fill")
                                .foregroundColor(.yellow)
                            Text("Start Your 7-Day Free Trial")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        
                        Text("No credit card required • Full access to all features")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 8)
                }
                
                Spacer()
                
                // Sign In Section
                VStack(spacing: 20) {
                    Text("Sign in to start your free trial")
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    // Apple Sign In Button (Primary CTA)
                    SignInWithAppleButton(
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            authService.handleAppleSignIn(result: result)
                        }
                    )
                    .signInWithAppleButtonStyle(.white)
                    .frame(height: 55)
                    .disabled(authService.isLoading)
                    
                    // Google Sign In Button (Primary CTA)
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
                    .frame(height: 55)
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
                
                // Footer info with email/password link
                VStack(spacing: 12) {
                    // Organization/Test Account Link (De-emphasized)
                    NavigationLink(destination: EmailPasswordLoginView()) {
                        Text("Existing org/test account? Log in")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .underline()
                    }
                    
                    Text("Trusted by students worldwide")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("Cancel anytime during trial")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
        }
        .onChange(of: authService.isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                print("✅ User authenticated in view")
            }
        }
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(AuthenticationService())
}
