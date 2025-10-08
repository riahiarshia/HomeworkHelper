import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var username = ""
    @State private var selectedAge: Int = 10
    @State private var selectedGrade: String = "4th grade"
    @State private var useGrade = false
    @State private var isCompleted = false
    
    private let ages = Array(5...18)
    private let grades = [
        "Kindergarten", "1st grade", "2nd grade", "3rd grade", "4th grade", "5th grade",
        "6th grade", "7th grade", "8th grade", "9th grade", "10th grade", "11th grade", "12th grade"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    headerView
                    userInfoSection
                    ageGradeSection
                    continueButton
                }
                .padding()
            }
            .navigationTitle("Welcome!")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
        }
        .onAppear {
            // Pre-fill username if user already exists and it's not a generic name
            if let existingUser = dataManager.currentUser {
                let existingName = existingUser.username
                // Only pre-fill if it's not a generic name
                if existingName.lowercased() != "apple user" && 
                   existingName.lowercased() != "google user" &&
                   existingName.lowercased() != "user" {
                    username = existingName
                }
                selectedAge = existingUser.age ?? 10
                selectedGrade = existingUser.grade ?? "4th grade"
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            Image(systemName: "graduationcap.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Welcome to Homework Helper!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Let's get to know you so we can provide the best learning experience.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 40)
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
    
    private var ageGradeSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Tell us about your grade level")
                .font(.headline)
            
            // Toggle between age and grade selection
            Picker("Select method", selection: $useGrade) {
                Text("By Age").tag(false)
                Text("By Grade").tag(true)
            }
            .pickerStyle(SegmentedPickerStyle())
            
            if useGrade {
                gradeSelectionView
            } else {
                ageSelectionView
            }
        }
    }
    
    private var ageSelectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How old are you?")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Picker("Age", selection: $selectedAge) {
                ForEach(ages, id: \.self) { age in
                    Text("\(age) years old").tag(age)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(height: 120)
        }
    }
    
    private var gradeSelectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What grade are you in?")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Picker("Grade", selection: $selectedGrade) {
                ForEach(grades, id: \.self) { grade in
                    Text(grade).tag(grade)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(height: 120)
        }
    }
    
    private var continueButton: some View {
        Button {
            saveUserInfo()
        } label: {
            Text("Get Started!")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isValidName ? Color.blue : Color.gray)
                .cornerRadius(12)
        }
        .disabled(!isValidName)
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
        guard !username.isEmpty else { return }
        
        let trimmedName = username.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Update existing user instead of creating a new one to preserve auth data
        if var user = dataManager.currentUser {
            // Update the onboarding fields
            user.username = trimmedName
            user.age = useGrade ? nil : selectedAge
            user.grade = useGrade ? selectedGrade : nil
            dataManager.currentUser = user
            
            // Sync to backend if authenticated
            if let userId = user.userId, let token = user.authToken {
                syncProfileToBackend(userId: userId, token: token, username: trimmedName, age: user.age, grade: user.grade)
            }
        } else {
            // Fallback: create new user if none exists
            let user = User(
                username: trimmedName,
                age: useGrade ? nil : selectedAge,
                grade: useGrade ? selectedGrade : nil
            )
            dataManager.currentUser = user
        }
        
        dataManager.saveData()
        isCompleted = true
    }
    
    private func syncProfileToBackend(userId: String, token: String, username: String, age: Int?, grade: String?) {
        guard let url = URL(string: "https://homework-helper-api.azurewebsites.net/api/auth/update-profile") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "username": username,
            "age": age as Any,
            "grade": grade as Any
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("⚠️ Onboarding profile sync error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("✅ Onboarding profile synced to backend: \(username)")
            } else {
                print("⚠️ Onboarding profile sync failed with status: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
            }
        }.resume()
    }
}

#Preview {
    OnboardingView()
        .environmentObject(DataManager.shared)
}
