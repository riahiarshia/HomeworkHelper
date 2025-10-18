import SwiftUI

struct ProfileSetupView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var username = ""
    @State private var selectedGrade: String = "4th grade"
    @State private var isCompleted = false
    @State private var showingNameAlert = false
    
    private let grades = [
        "Kindergarten", "1st grade", "2nd grade", "3rd grade", "4th grade", "5th grade",
        "6th grade", "7th grade", "8th grade", "9th grade", "10th grade", "11th grade", "12th grade",
        "College - Freshman", "College - Sophomore", "College - Junior", "College - Senior", "Graduate School"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    headerView
                    userInfoSection
                    gradeSection
                    continueButton
                }
                .padding()
            }
            .navigationTitle("Complete Your Profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .alert("Name Required", isPresented: $showingNameAlert) {
                Button("OK") { }
            } message: {
                Text("Please enter your name before continuing.")
            }
        }
        .onAppear {
            // Don't pre-fill username - user must enter their own name
            // Only pre-fill grade if it exists
            if let existingUser = dataManager.currentUser {
                selectedGrade = existingUser.grade ?? "4th grade"
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            // Custom logo
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
            
            Text("Let's personalize your experience!")  
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Tell us a bit about yourself so we can provide the best learning experience.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }
    
    private var userInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What's your name?")
                .font(.headline)
            
            TextField("Enter your full name", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.words)
            
            Text("We'll use this to personalize your experience and for account support.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var gradeSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("What's your grade level?")
                .font(.headline)
            
            Text("Select your current grade or education level")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Picker("Grade", selection: $selectedGrade) {
                ForEach(grades, id: \.self) { grade in
                    Text(grade).tag(grade)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(height: 150)
        }
    }
    
    private var continueButton: some View {
        Button {
            if isValidName {
                saveUserInfo()
            } else {
                showingNameAlert = true
            }
        } label: {
            Text("Get Started!")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
        }
        .padding(.top, 20)
    }
    
    private var isValidName: Bool {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        // Require at least 2 characters and not generic names
        let isGeneric = trimmed.lowercased() == "apple user" ||
                       trimmed.lowercased() == "google user" ||
                       trimmed.lowercased() == "user"
        
        return trimmed.count >= 2 && !isGeneric
    }
    
    private func saveUserInfo() {
        guard isValidName else { return }
        
        let trimmedName = username.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Update existing user instead of creating a new one to preserve auth data
        if var user = dataManager.currentUser {
            // Update the onboarding fields
            user.username = trimmedName
            user.age = nil // Always set age to nil since we're removing it
            user.grade = selectedGrade
            dataManager.currentUser = user
            
            // CRITICAL: Also sync to AuthenticationService so it persists
            NotificationCenter.default.post(
                name: NSNotification.Name("ProfileUpdated"),
                object: nil,
                userInfo: ["user": user]
            )
            
            // Sync to backend if authenticated
            if let userId = user.userId, let token = user.authToken {
                syncProfileToBackend(userId: userId, token: token, username: trimmedName, grade: user.grade)
            }
        } else {
            // Fallback: create new user if none exists
            let user = User(
                username: trimmedName,
                age: nil, // Always set age to nil
                grade: selectedGrade
            )
            dataManager.currentUser = user
        }
        
        dataManager.saveData()
        isCompleted = true
    }
    
    private func syncProfileToBackend(userId: String, token: String, username: String, grade: String?) {
        guard let url = URL(string: "\(Config.apiBaseURL)/api/auth/update-profile") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "username": username,
            "age": NSNull(), // Always send null for age
            "grade": grade as Any
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("⚠️ Profile setup sync error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("✅ Profile setup synced to backend: \(username)")
            } else {
                print("⚠️ Profile setup sync failed with status: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
            }
        }.resume()
    }
}

#Preview {
    ProfileSetupView()
        .environmentObject(DataManager.shared)
}
