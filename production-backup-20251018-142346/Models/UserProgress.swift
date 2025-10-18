import Foundation

struct UserProgress: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    var subject: String
    var problemsSolved: Int
    var totalPoints: Int
    var averageScore: Double
    var lastUpdated: Date
    
    init(
        id: UUID = UUID(),
        userId: UUID,
        subject: String,
        problemsSolved: Int = 0,
        totalPoints: Int = 0,
        averageScore: Double = 0.0,
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.subject = subject
        self.problemsSolved = problemsSolved
        self.totalPoints = totalPoints
        self.averageScore = averageScore
        self.lastUpdated = lastUpdated
    }
}
