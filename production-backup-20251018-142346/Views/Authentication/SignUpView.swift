import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authService: AuthenticationService
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var selectedAge: Int = 10
    @State private var selectedGrade: String = "4th grade"
    @State private var useGrade = false
    @State private var showingAgeGradeSelection = false
    
    private let ages = Array(5...18)
    private let grades = [
        "Kindergarten", "1st grade", "2nd grade", "3rd grade", "4th grade", "5th grade",
        "6th grade", "7th grade", "8th grade", "9th grade", "10th grade", "11th grade", "12th grade"
    ]
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Create Account")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Join HomeworkHelper and start your learning journey")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerView
                    
                    // Form
                    VStack(spacing: 16) {
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            TextField("Enter your email", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            SecureField("Create a password", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // Confirm Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            SecureField("Confirm your password", text: $confirmPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // Age/Grade Selection Toggle
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Student Information")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Picker("Information Type", selection: $useGrade) {
                                Text("Age").tag(false)
                                Text("Grade").tag(true)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            
                            if useGrade {
                                gradeSelectionView
                            } else {
                                ageSelectionView
                            }
                        }
                    }
                    
                    // Validation Requirements
                    if !isFormValid {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Requirements:")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            validationItem("Valid email address", isValid: email.contains("@") && !email.isEmpty)
                            validationItem("Password at least 6 characters", isValid: password.count >= 6)
                            validationItem("Passwords match", isValid: !password.isEmpty && password == confirmPassword)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // Error Message
                    if let errorMessage = authService.errorMessage {
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                    
                    // Sign Up Button
                    Button(action: {
                        print("🔍 DEBUG SignUpView: Create Account button tapped")
                        print("   Email: \(email)")
                        print("   Password length: \(password.count)")
                        print("   Passwords match: \(password == confirmPassword)")
                        print("   Using grade: \(useGrade)")
                        print("   Age: \(useGrade ? "N/A" : "\(selectedAge)")")
                        print("   Grade: \(useGrade ? selectedGrade : "N/A")")
                        
                        // Use signUpWithEmail method - age/grade stored in profile setup later
                        authService.signUpWithEmail(
                            email: email,
                            password: password,
                            username: email.split(separator: "@").first.map(String.init) ?? "User"
                        )
                    }) {
                        HStack {
                            if authService.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text("Create Account")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? Color.blue : Color.gray)
                        .cornerRadius(12)
                    }
                    .disabled(!isFormValid || authService.isLoading)
                    
                    // Terms and Privacy
                    VStack(spacing: 8) {
                        Text("By creating an account, you agree to our")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 4) {
                            Button("Terms of Service") {
                                // Handle terms
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                            
                            Text("and")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Button("Privacy Policy") {
                                // Handle privacy
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
            )
        }
        .onChange(of: authService.isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                dismiss()
            }
        }
    }
    
    private var ageSelectionView: some View {
        Picker("Age", selection: $selectedAge) {
            ForEach(ages, id: \.self) { age in
                Text("\(age) years old").tag(age)
            }
        }
        .pickerStyle(WheelPickerStyle())
        .frame(height: 120)
    }
    
    private var gradeSelectionView: some View {
        Picker("Grade", selection: $selectedGrade) {
            ForEach(grades, id: \.self) { grade in
                Text(grade).tag(grade)
            }
        }
        .pickerStyle(WheelPickerStyle())
        .frame(height: 120)
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && 
        !password.isEmpty && 
        !confirmPassword.isEmpty &&
        email.contains("@") &&
        password == confirmPassword &&
        password.count >= 6
    }
    
    private func validationItem(_ text: String, isValid: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: isValid ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isValid ? .green : .gray)
                .font(.caption)
            Text(text)
                .font(.caption)
                .foregroundColor(isValid ? .primary : .secondary)
        }
    }
}

#Preview {
    SignUpView()
        .environmentObject(AuthenticationService())
}
