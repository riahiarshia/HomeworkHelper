import Foundation

struct User: Codable, Identifiable, Equatable {
    let id: UUID
    var username: String
    var age: Int?
    var grade: String?
    var points: Int
    var streak: Int
    var lastActive: Date
    
    // Authentication fields
    var userId: String?  // Backend user ID
    var email: String?
    var authToken: String?
    
    // Subscription fields
    var subscriptionStatus: String?  // 'trial', 'active', 'expired'
    var subscriptionEndDate: Date?
    var daysRemaining: Int?
    
    init(id: UUID = UUID(), username: String, age: Int? = nil, grade: String? = nil, points: Int = 0, streak: Int = 0, lastActive: Date = Date(), userId: String? = nil, email: String? = nil, authToken: String? = nil, subscriptionStatus: String? = nil, subscriptionEndDate: Date? = nil, daysRemaining: Int? = nil) {
        self.id = id
        self.username = username
        self.age = age
        self.grade = grade
        self.points = points
        self.streak = streak
        self.lastActive = lastActive
        self.userId = userId
        self.email = email
        self.authToken = authToken
        self.subscriptionStatus = subscriptionStatus
        self.subscriptionEndDate = subscriptionEndDate
        self.daysRemaining = daysRemaining
    }
    
    // Helper function to get grade level for AI prompts
    func getGradeLevel() -> String {
        if let grade = grade {
            return grade
        }
        return "elementary" // Default fallback
    }
    
    // Helper function to determine if user can handle algebraic concepts
    func canHandleAlgebra() -> Bool {
        guard let grade = grade else { return false }
        return grade.contains("6th") || grade.contains("7th") || grade.contains("8th") || 
               grade.contains("9th") || grade.contains("10th") || grade.contains("11th") || 
               grade.contains("12th") || grade.contains("College") || grade.contains("Graduate")
    }
    
    // Helper function to determine if user can handle complex math
    func canHandleComplexMath() -> Bool {
        guard let grade = grade else { return false }
        return grade.contains("9th") || grade.contains("10th") || grade.contains("11th") || 
               grade.contains("12th") || grade.contains("College") || grade.contains("Graduate")
    }
}
