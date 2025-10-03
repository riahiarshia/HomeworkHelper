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
            // Pre-fill username if user already exists
            if let existingUser = dataManager.currentUser {
                username = existingUser.username
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
            
            TextField("Enter your name", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.words)
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
                .background(username.isEmpty ? Color.gray : Color.blue)
                .cornerRadius(12)
        }
        .disabled(username.isEmpty)
        .padding(.top, 20)
    }
    
    private func saveUserInfo() {
        guard !username.isEmpty else { return }
        
        let user = User(
            username: username,
            age: useGrade ? nil : selectedAge,
            grade: useGrade ? selectedGrade : nil
        )
        
        dataManager.currentUser = user
        dataManager.saveData()
        isCompleted = true
    }
}

#Preview {
    OnboardingView()
        .environmentObject(DataManager.shared)
}
