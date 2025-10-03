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
            currentUser = User(username: "Student", age: nil, grade: nil, points: 0, streak: 0)
            saveData()
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
    
    func addProblem(_ problem: HomeworkProblem) {
        problems.append(problem)
        saveData()
    }
    
    func updateProblem(_ problem: HomeworkProblem) {
        if let index = problems.firstIndex(where: { $0.id == problem.id }) {
            problems[index] = problem
            saveData()
        }
    }
    
    func addStep(_ step: GuidanceStep, for problemId: UUID) {
        let key = problemId.uuidString
        if steps[key] == nil {
            steps[key] = []
        }
        steps[key]?.append(step)
        saveData()
    }
    
    func updateStep(_ step: GuidanceStep, for problemId: UUID) {
        let key = problemId.uuidString
        if let index = steps[key]?.firstIndex(where: { $0.id == step.id }) {
            steps[key]?[index] = step
            saveData()
        }
    }
    
    func addMessage(_ message: ChatMessage, for problemId: UUID) {
        let key = problemId.uuidString
        if messages[key] == nil {
            messages[key] = []
        }
        messages[key]?.append(message)
        saveData()
    }
    
    func updateUserPoints(_ points: Int) {
        currentUser?.points += points
        saveData()
    }
    
    func updateProgress(subject: String, points: Int) {
        if let index = progress.firstIndex(where: { $0.subject == subject && $0.userId == currentUser?.id }) {
            progress[index].problemsSolved += 1
            progress[index].totalPoints += points
            progress[index].averageScore = Double(progress[index].totalPoints) / Double(progress[index].problemsSolved)
            progress[index].lastUpdated = Date()
        } else if let userId = currentUser?.id {
            let newProgress = UserProgress(
                userId: userId,
                subject: subject,
                problemsSolved: 1,
                totalPoints: points,
                averageScore: Double(points),
                lastUpdated: Date()
            )
            progress.append(newProgress)
        }
        saveData()
    }
}
