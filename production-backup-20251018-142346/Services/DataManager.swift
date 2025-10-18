import Foundation

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var currentUser: User?
    @Published var problems: [HomeworkProblem] = []
    @Published var steps: [String: [GuidanceStep]] = [:]
    @Published var messages: [String: [ChatMessage]] = [:]
    @Published var progress: [UserProgress] = []
    
    private let fileManager = FileManager.default
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private init() {
        // Don't load data here - wait for user to be set
        setupDefaultUser()
    }
    
    private func setupDefaultUser() {
        if currentUser == nil {
            // Don't create a default user - let the onboarding flow handle user creation
            // This prevents the app from getting stuck in onboarding loop
            print("🔍 DEBUG DataManager: No existing user found, onboarding will be shown")
        }
    }
    
    // MARK: - User-Specific File Paths
    
    private func getProblemsFilePath(for userId: String) -> URL {
        return documentsDirectory.appendingPathComponent("user_\(userId)_problems.json")
    }
    
    private func getStepsFilePath(for userId: String) -> URL {
        return documentsDirectory.appendingPathComponent("user_\(userId)_steps.json")
    }
    
    private func getMessagesFilePath(for userId: String) -> URL {
        return documentsDirectory.appendingPathComponent("user_\(userId)_messages.json")
    }
    
    private func getProgressFilePath(for userId: String) -> URL {
        return documentsDirectory.appendingPathComponent("user_\(userId)_progress.json")
    }
    
    // MARK: - User Context Management
    
    /// Call this when a user logs in to load their homework data
    func setCurrentUser(_ user: User) {
        print("📂 DataManager: Setting current user: \(user.email ?? "unknown")")
        
        // Defer updates to avoid publishing during view updates
        Task { @MainActor in
            self.currentUser = user
            
            // Clear current data
            self.problems = []
            self.steps = [:]
            self.messages = [:]
            self.progress = []
            
            // Load user-specific data if userId exists
            if let userId = user.userId {
                self.loadUserData(for: userId)
            } else {
                print("⚠️ DataManager: User has no userId, using empty data")
            }
        }
    }
    
    /// Call this when user logs out
    func clearCurrentUser() {
        print("📂 DataManager: Clearing current user (homework data preserved)")
        currentUser = nil
        problems = []
        steps = [:]
        messages = [:]
        progress = []
    }
    
    // MARK: - Save Data (User-Specific)
    
    func saveData() {
        // Only save if we have a userId
        guard let userId = currentUser?.userId else {
            print("⚠️ DataManager: Cannot save data - no userId")
            return
        }
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            // Save homework data to user-specific files
            let problemsData = try encoder.encode(problems)
            try problemsData.write(to: getProblemsFilePath(for: userId))
            
            let stepsData = try encoder.encode(steps)
            try stepsData.write(to: getStepsFilePath(for: userId))
            
            let messagesData = try encoder.encode(messages)
            try messagesData.write(to: getMessagesFilePath(for: userId))
            
            let progressData = try encoder.encode(progress)
            try progressData.write(to: getProgressFilePath(for: userId))
            
            print("💾 DataManager: Saved data for user \(userId)")
        } catch {
            print("❌ Error saving data: \(error)")
        }
    }
    
    // MARK: - Load Data (User-Specific)
    
    private func loadUserData(for userId: String) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        print("📂 DataManager: Loading data for user \(userId)")
        
        do {
            // Load problems
            let problemsURL = getProblemsFilePath(for: userId)
            if fileManager.fileExists(atPath: problemsURL.path) {
                let problemsData = try Data(contentsOf: problemsURL)
                problems = try decoder.decode([HomeworkProblem].self, from: problemsData)
                print("✅ Loaded \(problems.count) problems")
            }
            
            // Load steps
            let stepsURL = getStepsFilePath(for: userId)
            if fileManager.fileExists(atPath: stepsURL.path) {
                let stepsData = try Data(contentsOf: stepsURL)
                steps = try decoder.decode([String: [GuidanceStep]].self, from: stepsData)
                print("✅ Loaded steps for \(steps.count) problems")
            }
            
            // Load messages
            let messagesURL = getMessagesFilePath(for: userId)
            if fileManager.fileExists(atPath: messagesURL.path) {
                let messagesData = try Data(contentsOf: messagesURL)
                messages = try decoder.decode([String: [ChatMessage]].self, from: messagesData)
                print("✅ Loaded messages for \(messages.count) problems")
            }
            
            // Load progress
            let progressURL = getProgressFilePath(for: userId)
            if fileManager.fileExists(atPath: progressURL.path) {
                let progressData = try Data(contentsOf: progressURL)
                progress = try decoder.decode([UserProgress].self, from: progressData)
                print("✅ Loaded \(progress.count) progress records")
            }
        } catch {
            print("❌ Error loading data: \(error)")
        }
    }
    
    // MARK: - Clear Homework Data
    
    /// Clears homework data for the current user (but preserves authentication)
    func clearHomeworkData() {
        guard let userId = currentUser?.userId else {
            print("⚠️ DataManager: Cannot clear data - no userId")
            return
        }
        
        print("🗑️ DataManager: Clearing homework data for user \(userId)")
        
        // Clear in-memory data
        problems = []
        steps = [:]
        messages = [:]
        progress = []
        
        // Delete user-specific files
        do {
            try? fileManager.removeItem(at: getProblemsFilePath(for: userId))
            try? fileManager.removeItem(at: getStepsFilePath(for: userId))
            try? fileManager.removeItem(at: getMessagesFilePath(for: userId))
            try? fileManager.removeItem(at: getProgressFilePath(for: userId))
            
            // Delete associated images
            for problem in problems {
                if let filename = problem.imageFilename {
                    deleteImage(filename: filename)
                }
            }
            
            print("✅ Cleared homework data for user \(userId)")
        }
    }
    
    /// Clears ALL data (used for account deletion)
    func clearAllData() {
        guard let userId = currentUser?.userId else {
            print("⚠️ DataManager: Cannot clear all data - no userId")
            return
        }
        
        print("🗑️ DataManager: Clearing ALL data for account deletion")
        
        // Clear homework data first
        clearHomeworkData()
        
        // Delete ALL user-specific files (including any we might have missed)
        do {
            let files = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            for file in files {
                if file.lastPathComponent.contains("user_\(userId)") {
                    try? fileManager.removeItem(at: file)
                    print("🗑️ Deleted: \(file.lastPathComponent)")
                }
            }
        } catch {
            print("❌ Error deleting user files: \(error)")
        }
        
        // Clear current user
        currentUser = nil
        
        print("✅ DataManager: Successfully cleared all data for account deletion")
    }
    
    func saveImage(_ imageData: Data, forProblemId problemId: UUID, suffix: String = "") -> String? {
        let filename = "\(problemId.uuidString)\(suffix).jpg"
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        do {
            try imageData.write(to: fileURL)
            return filename
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
    
    func loadImage(filename: String) -> Data? {
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        return try? Data(contentsOf: fileURL)
    }
    
    func deleteImage(filename: String) {
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    func addProblem(_ problem: HomeworkProblem) {
        print("🔍 DEBUG DataManager.addProblem:")
        print("   Problem ID: \(problem.id)")
        print("   Subject: \(problem.subject ?? "Unknown")")
        print("   Total Steps: \(problem.totalSteps)")
        
        DispatchQueue.main.async {
            self.problems.append(problem)
            print("🔍 DEBUG DataManager.addProblem: Added problem. Total problems: \(self.problems.count)")
            self.saveData()
            print("🔍 DEBUG DataManager.addProblem: Saved data after adding problem")
        }
    }
    
    func updateProblem(_ problem: HomeworkProblem) {
        DispatchQueue.main.async {
            if let index = self.problems.firstIndex(where: { $0.id == problem.id }) {
                self.problems[index] = problem
                self.saveData()
            }
        }
    }
    
    func addStep(_ step: GuidanceStep, for problemId: UUID) {
        print("🔍 DEBUG DataManager.addStep:")
        print("   Problem ID: \(problemId.uuidString)")
        print("   Step ID: \(step.id)")
        print("   Step Number: \(step.stepNumber)")
        print("   Question: \(step.question)")
        
        DispatchQueue.main.async {
            let key = problemId.uuidString
            if self.steps[key] == nil {
                print("🔍 DEBUG DataManager.addStep: Creating new steps array for problem \(key)")
                self.steps[key] = []
            }
            
            self.steps[key]?.append(step)
            print("🔍 DEBUG DataManager.addStep: Added step. Total steps for problem \(key): \(self.steps[key]?.count ?? 0)")
            
            self.saveData()
            print("🔍 DEBUG DataManager.addStep: Saved data after adding step")
        }
    }
    
    func updateStep(_ step: GuidanceStep, for problemId: UUID) {
        DispatchQueue.main.async {
            let key = problemId.uuidString
            if let index = self.steps[key]?.firstIndex(where: { $0.id == step.id }) {
                self.steps[key]?[index] = step
                self.saveData()
            }
        }
    }
    
    func addMessage(_ message: ChatMessage, for problemId: UUID) {
        DispatchQueue.main.async {
            let key = problemId.uuidString
            if self.messages[key] == nil {
                self.messages[key] = []
            }
            self.messages[key]?.append(message)
            self.saveData()
        }
    }
    
    func updateUserPoints(_ points: Int) {
        DispatchQueue.main.async {
            self.currentUser?.points += points
            self.saveData()
        }
    }
    
    func updateProgress(subject: String, points: Int) {
        DispatchQueue.main.async {
            if let index = self.progress.firstIndex(where: { $0.subject == subject && $0.userId == self.currentUser?.id }) {
                self.progress[index].problemsSolved += 1
                self.progress[index].totalPoints += points
                self.progress[index].averageScore = Double(self.progress[index].totalPoints) / Double(self.progress[index].problemsSolved)
                self.progress[index].lastUpdated = Date()
            } else if let userId = self.currentUser?.id {
                let newProgress = UserProgress(
                    userId: userId,
                    subject: subject,
                    problemsSolved: 1,
                    totalPoints: points,
                    averageScore: Double(points),
                    lastUpdated: Date()
                )
                self.progress.append(newProgress)
            }
            self.saveData()
        }
    }
}
