import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var username: String = ""
    @State private var selectedAge: Int = 10
    @State private var selectedGrade: String = "4th grade"
    @State private var useGrade = false
    @State private var showingSaveAlert = false
    
    private let ages = Array(5...18)
    private let grades = [
        "Kindergarten", "1st grade", "2nd grade", "3rd grade", "4th grade", "5th grade",
        "6th grade", "7th grade", "8th grade", "9th grade", "10th grade", "11th grade", "12th grade"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Username", text: $username)
                        .autocapitalization(.words)
                }
                
                Section(header: Text("Grade Level")) {
                    Picker("Select method", selection: $useGrade) {
                        Text("By Age").tag(false)
                        Text("By Grade").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if useGrade {
                        Picker("Grade", selection: $selectedGrade) {
                            ForEach(grades, id: \.self) { grade in
                                Text(grade).tag(grade)
                            }
                        }
                    } else {
                        Picker("Age", selection: $selectedAge) {
                            ForEach(ages, id: \.self) { age in
                                Text("\(age) years old").tag(age)
                            }
                        }
                    }
                }
                
                Section(footer: Text("This information helps us provide age-appropriate learning guidance.")) {
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
        selectedAge = user.age ?? 10
        selectedGrade = user.grade ?? "4th grade"
        useGrade = user.grade != nil
    }
    
    private func saveProfile() {
        guard !username.isEmpty else { return }
        
        let updatedUser = User(
            id: dataManager.currentUser?.id ?? UUID(),
            username: username,
            age: useGrade ? nil : selectedAge,
            grade: useGrade ? selectedGrade : nil,
            points: dataManager.currentUser?.points ?? 0,
            streak: dataManager.currentUser?.streak ?? 0,
            lastActive: Date()
        )
        
        dataManager.currentUser = updatedUser
        dataManager.saveData()
        showingSaveAlert = true
    }
}

#Preview {
    EditProfileView()
        .environmentObject(DataManager.shared)
}
