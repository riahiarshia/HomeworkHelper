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
        loadData()
        setupDefaultUser()
    }
    
    private func setupDefaultUser() {
        if currentUser == nil {
            // Don't create a default user - let the onboarding flow handle user creation
            // This prevents the app from getting stuck in onboarding loop
            print("🔍 DEBUG DataManager: No existing user found, onboarding will be shown")
        }
    }
    
    func saveData() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            if let user = currentUser {
                let userData = try encoder.encode(user)
                try userData.write(to: documentsDirectory.appendingPathComponent("user.json"))
            }
            
            let problemsData = try encoder.encode(problems)
            try problemsData.write(to: documentsDirectory.appendingPathComponent("problems.json"))
            
            let stepsData = try encoder.encode(steps)
            try stepsData.write(to: documentsDirectory.appendingPathComponent("steps.json"))
            
            let messagesData = try encoder.encode(messages)
            try messagesData.write(to: documentsDirectory.appendingPathComponent("messages.json"))
            
            let progressData = try encoder.encode(progress)
            try progressData.write(to: documentsDirectory.appendingPathComponent("progress.json"))
            
        } catch {
            print("Error saving data: \(error)")
        }
    }
    
    func loadData() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let userURL = documentsDirectory.appendingPathComponent("user.json")
            if fileManager.fileExists(atPath: userURL.path) {
                let userData = try Data(contentsOf: userURL)
                currentUser = try decoder.decode(User.self, from: userData)
            }
            
            let problemsURL = documentsDirectory.appendingPathComponent("problems.json")
            if fileManager.fileExists(atPath: problemsURL.path) {
                let problemsData = try Data(contentsOf: problemsURL)
                problems = try decoder.decode([HomeworkProblem].self, from: problemsData)
            }
            
            let stepsURL = documentsDirectory.appendingPathComponent("steps.json")
            if fileManager.fileExists(atPath: stepsURL.path) {
                let stepsData = try Data(contentsOf: stepsURL)
                steps = try decoder.decode([String: [GuidanceStep]].self, from: stepsData)
            }
            
            let messagesURL = documentsDirectory.appendingPathComponent("messages.json")
            if fileManager.fileExists(atPath: messagesURL.path) {
                let messagesData = try Data(contentsOf: messagesURL)
                messages = try decoder.decode([String: [ChatMessage]].self, from: messagesData)
            }
            
            let progressURL = documentsDirectory.appendingPathComponent("progress.json")
            if fileManager.fileExists(atPath: progressURL.path) {
                let progressData = try Data(contentsOf: progressURL)
                progress = try decoder.decode([UserProgress].self, from: progressData)
            }
        } catch {
            print("Error loading data: \(error)")
        }
    }
    
    func saveImage(_ imageData: Data, forProblemId problemId: UUID) -> String? {
        let filename = "\(problemId.uuidString).jpg"
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
