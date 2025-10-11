import Foundation

struct GuidanceStep: Codable, Identifiable {
    let id: UUID
    let problemId: UUID
    var stepNumber: Int
    var question: String
    var explanation: String
    var options: [String]
    var correctAnswer: String
    var userAnswer: String?
    var isCompleted: Bool
    var isSkipped: Bool
    var hintsUsed: Int
    var createdAt: Date
    var requiresPreviousSteps: Bool
    
    init(
        id: UUID = UUID(),
        problemId: UUID,
        stepNumber: Int,
        question: String,
        explanation: String,
        options: [String],
        correctAnswer: String,
        userAnswer: String? = nil,
        isCompleted: Bool = false,
        isSkipped: Bool = false,
        hintsUsed: Int = 0,
        createdAt: Date = Date(),
        requiresPreviousSteps: Bool = true
    ) {
        self.id = id
        self.problemId = problemId
        self.stepNumber = stepNumber
        self.question = question
        self.explanation = explanation
        self.options = options
        self.correctAnswer = correctAnswer
        self.userAnswer = userAnswer
        self.isCompleted = isCompleted
        self.isSkipped = isSkipped
        self.hintsUsed = hintsUsed
        self.createdAt = createdAt
        self.requiresPreviousSteps = requiresPreviousSteps
    }
}
