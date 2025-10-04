import Foundation
import UIKit

class BackendAPIService: ObservableObject {
    static let shared = BackendAPIService()
    
    @Published var isLoading = false
    @Published var error: String?
    @Published var progressMessage: String = ""
    @Published var isAnalyzing = false
    
    // Update this URL to your deployed backend
    private let baseURL = "https://homework-helper-backend-1759603081.azurewebsites.net" // Replace with your actual backend URL
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 180.0 // 3 minutes for image analysis
        config.timeoutIntervalForResource = 600.0 // 10 minutes total
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config)
        
        // Device-specific debugging
        print("🔍 DEBUG BackendAPIService init:")
        print("   Device: \(UIDevice.current.model)")
        print("   iOS Version: \(UIDevice.current.systemVersion)")
        print("   Timeout settings: Request=\(config.timeoutIntervalForRequest)s, Resource=\(config.timeoutIntervalForResource)s")
    }
    
    // MARK: - Image Quality Validation
    
    func validateImageQuality(imageData: Data) async throws -> ImageQualityValidation {
        await MainActor.run { isLoading = true }
        defer { 
            Task { @MainActor in
                isLoading = false
            }
        }
        
        let url = URL(string: "\(baseURL)/api/validate-image")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add image data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"homework.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Close boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw BackendAPIError.noResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorMessage = errorData["error"] as? String {
                    throw BackendAPIError.serverError(errorMessage)
                } else {
                    throw BackendAPIError.serverError("Server error: \(httpResponse.statusCode)")
                }
            }
            
            let validation = try JSONDecoder().decode(ImageQualityValidation.self, from: data)
            return validation
            
        } catch {
            if error is BackendAPIError {
                throw error
            } else {
                throw BackendAPIError.networkError(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Homework Analysis
    
    func analyzeHomework(imageData: Data?, problemText: String?, userGradeLevel: String) async throws -> ProblemAnalysis {
        print("🔍 DEBUG BackendAPIService.analyzeHomework:")
        print("   Image data provided: \(imageData != nil)")
        print("   Problem text provided: \(problemText != nil)")
        print("   User grade level: \(userGradeLevel)")
        print("   Base URL: \(baseURL)")
        
        await MainActor.run {
            isLoading = true
            isAnalyzing = true
            progressMessage = "Starting analysis..."
        }
        
        defer { 
            Task { @MainActor in
                isLoading = false
                isAnalyzing = false
                progressMessage = ""
            }
        }
        
        let url = URL(string: "\(baseURL)/api/analyze")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add image data if provided
        if let imageData = imageData {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"image\"; filename=\"homework.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        // Add problem text if provided
        if let problemText = problemText {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"problemText\"\r\n\r\n".data(using: .utf8)!)
            body.append(problemText.data(using: .utf8)!)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        // Add user grade level
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"userGradeLevel\"\r\n\r\n".data(using: .utf8)!)
        body.append(userGradeLevel.data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        
        // Close boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        // Start progress updates every 30 seconds
        let progressTask = Task {
            await updateProgressMessages()
        }
        
        do {
            print("🔍 DEBUG BackendAPIService: Making request to \(url)")
            print("🔍 DEBUG BackendAPIService: Network connectivity check...")
            
            // Check network connectivity first
            let reachability = try await checkNetworkConnectivity()
            print("🔍 DEBUG BackendAPIService: Network reachable: \(reachability)")
            
            let (data, response) = try await session.data(for: request)
            
            // Cancel progress updates
            progressTask.cancel()
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ DEBUG BackendAPIService: No HTTP response received")
                throw BackendAPIError.noResponse
            }
            
            print("🔍 DEBUG BackendAPIService: HTTP Status Code: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                print("❌ DEBUG BackendAPIService: HTTP Error \(httpResponse.statusCode)")
                if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorMessage = errorData["error"] as? String {
                    print("❌ DEBUG BackendAPIService: Server error message: \(errorMessage)")
                    throw BackendAPIError.serverError(errorMessage)
                } else {
                    let responseString = String(data: data, encoding: .utf8) ?? "No response data"
                    print("❌ DEBUG BackendAPIService: Raw response: \(responseString)")
                    throw BackendAPIError.serverError("Server error: \(httpResponse.statusCode)")
                }
            }
            
            print("🔍 DEBUG BackendAPIService: Successfully received response data")
            let responseString = String(data: data, encoding: .utf8) ?? "No response data"
            print("🔍 DEBUG BackendAPIService: Response data: \(responseString)")
            
            let analysis = try JSONDecoder().decode(ProblemAnalysis.self, from: data)
            print("🔍 DEBUG BackendAPIService: Successfully decoded analysis:")
            print("   Subject: \(analysis.subject)")
            print("   Difficulty: \(analysis.difficulty)")
            print("   Number of steps: \(analysis.steps.count)")
            for (index, step) in analysis.steps.enumerated() {
                print("   Step \(index + 1): \(step.question)")
            }
            
            return analysis
            
        } catch {
            print("❌ DEBUG BackendAPIService: Request failed with error: \(error)")
            if error is BackendAPIError {
                throw error
            } else {
                throw BackendAPIError.networkError(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Network Connectivity
    
    private func checkNetworkConnectivity() async throws -> Bool {
        guard let url = URL(string: "https://www.google.com") else {
            return false
        }
        
        do {
            let (_, response) = try await URLSession.shared.data(from: url)
            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 200
            }
            return false
        } catch {
            print("❌ DEBUG BackendAPIService: Network connectivity check failed: \(error)")
            return false
        }
    }
    
    // MARK: - Progress Updates
    
    private func updateProgressMessages() async {
        let messages = [
            "Analyzing your homework...",
            "Still analyzing... Please wait.",
            "Almost done... Keep waiting.",
            "Final processing... Almost there!"
        ]
        
        for (index, message) in messages.enumerated() {
            // Wait 30 seconds between messages
            try? await Task.sleep(nanoseconds: 30_000_000_000)
            
            // Check if we're still analyzing
            guard isAnalyzing else { break }
            
            await MainActor.run {
                progressMessage = message
            }
            
            // Stop after 90 seconds (3 messages)
            if index >= 2 { break }
        }
    }
    
    // MARK: - Hint Generation
    
    func generateHint(for step: GuidanceStep, problemContext: String, userGradeLevel: String) async throws -> String {
        await MainActor.run { isLoading = true }
        defer { 
            Task { @MainActor in
                isLoading = false
            }
        }
        
        let url = URL(string: "\(baseURL)/api/hint")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "step": [
                "question": step.question,
                "explanation": step.explanation,
                "options": step.options,
                "correctAnswer": step.correctAnswer
            ],
            "problemContext": problemContext,
            "userGradeLevel": userGradeLevel
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw BackendAPIError.noResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorMessage = errorData["error"] as? String {
                    throw BackendAPIError.serverError(errorMessage)
                } else {
                    throw BackendAPIError.serverError("Server error: \(httpResponse.statusCode)")
                }
            }
            
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let hint = json["hint"] as? String {
                return hint
            } else {
                throw BackendAPIError.invalidResponse
            }
            
        } catch {
            if error is BackendAPIError {
                throw error
            } else {
                throw BackendAPIError.networkError(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Answer Verification
    
    func verifyAnswer(answer: String, step: GuidanceStep, problemContext: String, userGradeLevel: String) async throws -> AnswerVerification {
        await MainActor.run { isLoading = true }
        defer { 
            Task { @MainActor in
                isLoading = false
            }
        }
        
        let url = URL(string: "\(baseURL)/api/verify")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "answer": answer,
            "step": [
                "question": step.question,
                "explanation": step.explanation,
                "options": step.options,
                "correctAnswer": step.correctAnswer
            ],
            "problemContext": problemContext,
            "userGradeLevel": userGradeLevel
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw BackendAPIError.noResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorMessage = errorData["error"] as? String {
                    throw BackendAPIError.serverError(errorMessage)
                } else {
                    throw BackendAPIError.serverError("Server error: \(httpResponse.statusCode)")
                }
            }
            
            let verification = try JSONDecoder().decode(AnswerVerification.self, from: data)
            return verification
            
        } catch {
            if error is BackendAPIError {
                throw error
            } else {
                throw BackendAPIError.networkError(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Health Check
    
    func checkHealth() async throws -> HealthStatus {
        let url = URL(string: "\(baseURL)/health")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw BackendAPIError.noResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw BackendAPIError.serverError("Health check failed: \(httpResponse.statusCode)")
            }
            
            let health = try JSONDecoder().decode(HealthStatus.self, from: data)
            return health
            
        } catch {
            if error is BackendAPIError {
                throw error
            } else {
                throw BackendAPIError.networkError(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Chat Response
    
    func generateChatResponse(messages: [ChatMessage], problemContext: String, userGradeLevel: String) async throws -> String {
        await MainActor.run { isLoading = true }
        defer { 
            Task { @MainActor in
                isLoading = false
            }
        }
        
        let url = URL(string: "\(baseURL)/api/chat")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ChatRequest(
            messages: messages,
            problemContext: problemContext,
            userGradeLevel: userGradeLevel
        )
        
        let jsonData = try JSONEncoder().encode(requestBody)
        request.httpBody = jsonData
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw BackendAPIError.noResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorMessage = errorData["error"] as? String {
                    throw BackendAPIError.serverError(errorMessage)
                } else {
                    throw BackendAPIError.serverError("Server error: \(httpResponse.statusCode)")
                }
            }
            
            let chatResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
            return chatResponse.response
            
        } catch {
            if error is BackendAPIError {
                throw error
            } else {
                throw BackendAPIError.networkError(error.localizedDescription)
            }
        }
    }
}

// MARK: - Supporting Types

struct AnswerVerification: Codable {
    let isCorrect: Bool
    let verification: String
}

struct HealthStatus: Codable {
    let status: String
    let timestamp: String
    let version: String
}

struct ImageQualityValidation: Codable {
    let isGoodQuality: Bool
    let confidence: Double
    let issues: [String]
    let recommendations: [String]
}

struct ChatRequest: Codable {
    let messages: [ChatMessage]
    let problemContext: String
    let userGradeLevel: String
}

struct ChatResponse: Codable {
    let response: String
}


enum BackendAPIError: Error, LocalizedError {
    case noResponse
    case invalidResponse
    case networkError(String)
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .noResponse:
            return "No response from server"
        case .invalidResponse:
            return "Invalid response format"
        case .networkError(let message):
            return "Network error: \(message)"
        case .serverError(let message):
            return "Server error: \(message)"
        }
    }
}
