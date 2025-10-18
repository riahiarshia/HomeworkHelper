import Foundation

struct ChatMessage: Codable, Identifiable {
    let id: UUID
    let problemId: UUID
    var role: MessageRole
    var content: String
    var timestamp: Date
    
    init(
        id: UUID = UUID(),
        problemId: UUID,
        role: MessageRole,
        content: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.problemId = problemId
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }
}

enum MessageRole: String, Codable {
    case user = "user"
    case assistant = "assistant"
    case system = "system"
}
