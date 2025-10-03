import XCTest
@testable import HomeworkHelper

final class HomeworkHelperTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // MARK: - Basic Logic Tests
    
    func testUserInitialization() throws {
        let user = User(username: "TestUser", points: 100, streak: 3)
        
        XCTAssertEqual(user.username, "TestUser")
        XCTAssertEqual(user.points, 100)
        XCTAssertEqual(user.streak, 3)
        XCTAssertNotNil(user.id)
    }
    
    func testHomeworkProblemCreation() throws {
        let userId = UUID()
        let problem = HomeworkProblem(
            userId: userId,
            problemText: "Solve 2x + 3 = 7",
            subject: "Mathematics"
        )
        
        XCTAssertEqual(problem.userId, userId)
        XCTAssertEqual(problem.problemText, "Solve 2x + 3 = 7")
        XCTAssertEqual(problem.subject, "Mathematics")
        XCTAssertEqual(problem.status, .pending)
        XCTAssertNotNil(problem.id)
    }
    
    func testGuidanceStepCreation() throws {
        let problemId = UUID()
        let step = GuidanceStep(
            problemId: problemId,
            stepNumber: 1,
            question: "What is the first step?",
            explanation: "Start by isolating the variable",
            options: ["Add 3", "Subtract 3", "Multiply by 2", "Divide by 2"],
            correctAnswer: "Subtract 3"
        )
        
        XCTAssertEqual(step.problemId, problemId)
        XCTAssertEqual(step.stepNumber, 1)
        XCTAssertEqual(step.question, "What is the first step?")
        XCTAssertEqual(step.options.count, 4)
        XCTAssertEqual(step.correctAnswer, "Subtract 3")
        XCTAssertFalse(step.isCompleted)
    }
    
    // MARK: - DataManager Tests
    
    func testDataManagerSingleton() throws {
        let dataManager1 = DataManager.shared
        let dataManager2 = DataManager.shared
        
        XCTAssertIdentical(dataManager1, dataManager2)
    }
    
    func testDataManagerAddProblem() throws {
        let dataManager = DataManager.shared
        let userId = UUID()
        let problem = HomeworkProblem(
            userId: userId,
            problemText: "Test problem",
            subject: "Math"
        )
        
        let initialCount = dataManager.problems.count
        dataManager.addProblem(problem)
        
        XCTAssertEqual(dataManager.problems.count, initialCount + 1)
        XCTAssertTrue(dataManager.problems.contains { $0.id == problem.id })
    }
    
    // MARK: - KeychainHelper Tests
    
    func testKeychainHelperSaveAndLoad() throws {
        let keychain = KeychainHelper.shared
        let testKey = "test_api_key"
        let testValue = "sk-test123456789"
        
        // Save the value
        let saveSuccess = keychain.save(testValue, forKey: testKey)
        XCTAssertTrue(saveSuccess)
        
        // Load the value
        let loadedValue = keychain.load(forKey: testKey)
        XCTAssertEqual(loadedValue, testValue)
        
        // Clean up
        _ = keychain.delete(forKey: testKey)
    }
    
    func testKeychainHelperDelete() throws {
        let keychain = KeychainHelper.shared
        let testKey = "test_delete_key"
        let testValue = "test_value"
        
        // Save a value
        _ = keychain.save(testValue, forKey: testKey)
        
        // Delete the value
        let deleteSuccess = keychain.delete(forKey: testKey)
        XCTAssertTrue(deleteSuccess)
        
        // Verify it's gone
        let loadedValue = keychain.load(forKey: testKey)
        XCTAssertNil(loadedValue)
    }
    
    // MARK: - Performance Tests
    
    func testDataManagerPerformance() throws {
        let dataManager = DataManager.shared
        
        measure {
            for i in 0..<100 {
                let problem = HomeworkProblem(
                    userId: UUID(),
                    problemText: "Performance test problem \(i)",
                    subject: "Math"
                )
                dataManager.addProblem(problem)
            }
        }
    }
    
    func testJSONEncodingPerformance() throws {
        let problems = (0..<1000).map { i in
            HomeworkProblem(
                userId: UUID(),
                problemText: "Problem \(i)",
                subject: "Math"
            )
        }
        
        measure {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            _ = try? encoder.encode(problems)
        }
    }
}
