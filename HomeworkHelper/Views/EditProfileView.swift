import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var username: String = ""
    @State private var selectedGrade: String = "4th grade"
    @State private var showingSaveAlert = false
    
    private let grades = [
        "Kindergarten", "1st grade", "2nd grade", "3rd grade", "4th grade", "5th grade",
        "6th grade", "7th grade", "8th grade", "9th grade", "10th grade", "11th grade", "12th grade",
        "College - Freshman", "College - Sophomore", "College - Junior", "College - Senior", "Graduate School"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Username", text: $username)
                        .autocapitalization(.words)
                }
                
                Section(header: Text("Grade Level")) {
                    Picker("Grade", selection: $selectedGrade) {
                        ForEach(grades, id: \.self) { grade in
                            Text(grade).tag(grade)
                        }
                    }
                }
                
                Section(footer: Text("This information helps us provide grade-appropriate learning guidance.")) {
                    EmptyView()
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                    .disabled(username.isEmpty)
                }
            }
            .onAppear {
                loadCurrentProfile()
            }
            .alert("Profile Updated", isPresented: $showingSaveAlert) {
                Button("OK") {
                    presentationMode.wrappedValue.dismiss()
                }
            } message: {
                Text("Your profile has been updated successfully.")
            }
        }
    }
    
    private func loadCurrentProfile() {
        guard let user = dataManager.currentUser else { return }
        
        username = user.username
        selectedGrade = user.grade ?? "4th grade"
    }
    
    private func saveProfile() {
        guard !username.isEmpty else { return }
        
        // Preserve authentication fields
        var updatedUser = dataManager.currentUser ?? User(username: username)
        updatedUser.username = username
        updatedUser.age = nil // Always set age to nil
        updatedUser.grade = selectedGrade
        updatedUser.lastActive = Date()
        
        dataManager.currentUser = updatedUser
        dataManager.saveData()
        
        // Sync to backend if authenticated
        if let userId = updatedUser.userId, let token = updatedUser.authToken {
            syncProfileToBackend(userId: userId, token: token, username: username, grade: updatedUser.grade)
        }
        
        showingSaveAlert = true
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
                print("⚠️ Profile sync error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("✅ Profile synced to backend successfully")
            } else {
                print("⚠️ Profile sync failed with status: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
            }
        }.resume()
    }
}

#Preview {
    EditProfileView()
        .environmentObject(DataManager.shared)
}
