import Foundation

struct HomeworkProblem: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    var problemText: String?
    var imageFilename: String?
    var teacherMethodImageFilename: String?
    var subject: String?
    var status: ProblemStatus
    var createdAt: Date
    var completedAt: Date?
    var totalSteps: Int
    var completedSteps: Int
    var skippedSteps: Int
    var pointsAwarded: Int?
    
    init(
        id: UUID = UUID(),
        userId: UUID,
        problemText: String? = nil,
        imageFilename: String? = nil,
        teacherMethodImageFilename: String? = nil,
        subject: String? = nil,
        status: ProblemStatus = .pending,
        createdAt: Date = Date(),
        completedAt: Date? = nil,
        totalSteps: Int = 0,
        completedSteps: Int = 0,
        skippedSteps: Int = 0,
        pointsAwarded: Int? = nil
    ) {
        self.id = id
        self.userId = userId
        self.problemText = problemText
        self.imageFilename = imageFilename
        self.teacherMethodImageFilename = teacherMethodImageFilename
        self.subject = subject
        self.status = status
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.totalSteps = totalSteps
        self.completedSteps = completedSteps
        self.skippedSteps = skippedSteps
        self.pointsAwarded = pointsAwarded
    }
}

enum ProblemStatus: String, Codable {
    case pending = "pending"
    case inProgress = "in_progress"
    case completed = "completed"
    case needsReview = "needs_review"
}
