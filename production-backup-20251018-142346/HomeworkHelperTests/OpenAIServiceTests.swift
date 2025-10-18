import XCTest
@testable import HomeworkHelper

final class OpenAIServiceTests: XCTestCase {
    
    var openAIService: OpenAIService!
    var mockSession: URLSession!
    
    override func setUpWithError() throws {
        super.setUp()
        
        // Configure URLProtocol to intercept requests
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self]
        mockSession = URLSession(configuration: config)
        
        openAIService = OpenAIService.shared
        openAIService.saveAPIKey("sk-test123456789")
        
        // Clear any existing stubs
        URLProtocolStub.removeAllStubs()
    }
    
    override func tearDownWithError() throws {
        URLProtocolStub.removeAllStubs()
        mockSession = nil
        openAIService = nil
        super.tearDown()
    }
    
    // MARK: - API Key Tests
    
    func testAPIKeyStorage() throws {
        let testKey = "sk-test123456789"
        openAIService.saveAPIKey(testKey)
        
        XCTAssertEqual(openAIService.apiKey, testKey)
    }
    
    // MARK: - Network Tests
    
    func testVerifyImageSuccess() async throws {
        // Setup mock response
        let mockResponse = """
        {
            "choices": [{
                "message": {
                    "content": "{\\"isValidHomework\\": true, \\"confidence\\": 0.9, \\"subject\\": \\"Mathematics\\", \\"readabilityScore\\": 0.8}"
                }
            }]
        }
        """
        
        URLProtocolStub.setupMockOpenAIResponse(
            for: "/chat/completions",
            jsonData: mockResponse.data(using: .utf8)!
        )
        
        // Create test image data
        let testImageData = Data("fake_image_data".utf8)
        
        // Test the method
        let result = try await openAIService.verifyImage(testImageData)
        
        XCTAssertTrue(result.isValidHomework)
        XCTAssertEqual(result.confidence, 0.9, accuracy: 0.01)
        XCTAssertEqual(result.subject, "Mathematics")
        XCTAssertEqual(result.readabilityScore, 0.8, accuracy: 0.01)
    }
    
    func testAnalyzeProblemSuccess() async throws {
        // Setup mock response
        let mockResponse = """
        {
            "choices": [{
                "message": {
                    "content": "{\\"subject\\": \\"Mathematics\\", \\"difficulty\\": \\"Intermediate\\", \\"steps\\": [{\\"question\\": \\"What is the first step?\\", \\"explanation\\": \\"Start by identifying the equation type\\", \\"options\\": [\\"Add both sides\\", \\"Subtract from both sides\\", \\"Multiply by 2\\"], \\"correctAnswer\\": \\"Add both sides\\"}]}"
                }
            }]
        }
        """
        
        URLProtocolStub.setupMockOpenAIResponse(
            for: "/chat/completions",
            jsonData: mockResponse.data(using: .utf8)!
        )
        
        // Test the method
        let result = try await openAIService.analyzeProblem(
            imageData: nil,
            problemText: "Solve 2x + 3 = 7"
        )
        
        XCTAssertEqual(result.subject, "Mathematics")
        XCTAssertEqual(result.difficulty, "Intermediate")
        XCTAssertEqual(result.steps.count, 1)
        XCTAssertEqual(result.steps[0].question, "What is the first step?")
        XCTAssertEqual(result.steps[0].correctAnswer, "Add both sides")
    }
    
    func testGenerateHintSuccess() async throws {
        // Setup mock response
        let mockResponse = """
        {
            "choices": [{
                "message": {
                    "content": "Think about isolating the variable by performing the opposite operation."
                }
            }]
        }
        """
        
        URLProtocolStub.setupMockOpenAIResponse(
            for: "/chat/completions",
            jsonData: mockResponse.data(using: .utf8)!
        )
        
        let step = GuidanceStep(
            problemId: UUID(),
            stepNumber: 1,
            question: "What is the first step?",
            explanation: "Start by isolating the variable",
            options: ["Add 3", "Subtract 3", "Multiply by 2"],
            correctAnswer: "Subtract 3"
        )
        
        let hint = try await openAIService.generateHint(
            for: step,
            problemContext: "Solve 2x + 3 = 7"
        )
        
        XCTAssertFalse(hint.isEmpty)
        XCTAssertTrue(hint.contains("variable"))
    }
    
    func testNetworkErrorHandling() async throws {
        // Setup error response
        let errorURL = URL(string: "https://api.openai.com/v1/chat/completions")!
        let error = URLError(.notConnectedToInternet)
        URLProtocolStub.stub(url: errorURL, data: nil, response: nil, error: error)
        
        // Test that error is properly thrown
        do {
            _ = try await openAIService.verifyImage(Data("test".utf8))
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is URLError)
        }
    }
    
    func testNoAPIKeyError() async throws {
        // Remove API key
        openAIService.saveAPIKey("")
        
        // Test that error is thrown when no API key
        do {
            _ = try await openAIService.verifyImage(Data("test".utf8))
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error.localizedDescription.contains("API key not set"))
        }
    }
    
    // MARK: - Performance Tests
    
    func testVerifyImagePerformance() async throws {
        let mockResponse = """
        {
            "choices": [{
                "message": {
                    "content": "{\\"isValidHomework\\": true, \\"confidence\\": 0.9, \\"subject\\": \\"Mathematics\\", \\"readabilityScore\\": 0.8}"
                }
            }]
        }
        """
        
        URLProtocolStub.setupMockOpenAIResponse(
            for: "/chat/completions",
            jsonData: mockResponse.data(using: .utf8)!
        )
        
        let testImageData = Data("fake_image_data".utf8)
        
        measure {
            Task {
                _ = try? await openAIService.verifyImage(testImageData)
            }
        }
    }
}
