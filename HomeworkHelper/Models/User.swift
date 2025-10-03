import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    var username: String
    var age: Int?
    var grade: String?
    var points: Int
    var streak: Int
    var lastActive: Date
    
    init(id: UUID = UUID(), username: String, age: Int? = nil, grade: String? = nil, points: Int = 0, streak: Int = 0, lastActive: Date = Date()) {
        self.id = id
        self.username = username
        self.age = age
        self.grade = grade
        self.points = points
        self.streak = streak
        self.lastActive = lastActive
    }
    
    // Helper function to get grade level for AI prompts
    func getGradeLevel() -> String {
        if let grade = grade {
            return grade
        }
        
        guard let age = age else {
            return "elementary" // Default fallback
        }
        
        switch age {
        case 5...7:
            return "kindergarten to 1st grade"
        case 8...9:
            return "2nd to 3rd grade"
        case 10...11:
            return "4th to 5th grade"
        case 12...14:
            return "6th to 8th grade (middle school)"
        case 15...18:
            return "9th to 12th grade (high school)"
        default:
            return "elementary"
        }
    }
    
    // Helper function to determine if user can handle algebraic concepts
    func canHandleAlgebra() -> Bool {
        guard let age = age else { return false }
        return age >= 12 // Middle school and up
    }
    
    // Helper function to determine if user can handle complex math
    func canHandleComplexMath() -> Bool {
        guard let age = age else { return false }
        return age >= 15 // High school and up
    }
}
