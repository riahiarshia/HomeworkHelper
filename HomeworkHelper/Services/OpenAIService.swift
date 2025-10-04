import Foundation
import UIKit

class OpenAIService: ObservableObject {
    static let shared = OpenAIService()
    
    @Published var apiKey: String = ""
    @Published var isLoadingFromAzure: Bool = false
    @Published var azureError: String?
    
    private let baseURL = "https://api.openai.com/v1"
    private let apiKeyKeychainKey = "OpenAIAPIKey"
    private let keychain = KeychainHelper.shared
    private let azureKeyVault = AzureKeyVaultService.shared
    
    private init() {
        // Try to load API key from keychain first (for offline use)
        loadAPIKey()
        
        // Then attempt to fetch from Azure Key Vault if configured
        Task {
            await loadAPIKeyFromAzure()
        }
    }
    
    // Load API key from Azure Key Vault
    func loadAPIKeyFromAzure() async {
        print("🔍 DEBUG OpenAIService.loadAPIKeyFromAzure:")
        
        guard azureKeyVault.isConfigured() else {
            print("🔍 DEBUG OpenAIService: Azure Key Vault not configured")
            await MainActor.run {
                azureError = "Azure Key Vault not configured. Using manual API key entry."
            }
            return
        }
        
        print("🔍 DEBUG OpenAIService: Azure Key Vault is configured, fetching API key...")
        
        await MainActor.run {
            isLoadingFromAzure = true
            azureError = nil
        }
        
        do {
            let key = try await azureKeyVault.fetchAPIKey()
            await MainActor.run {
                saveAPIKey(key)
                isLoadingFromAzure = false
                print("✅ DEBUG OpenAIService: Successfully loaded API key from Azure Key Vault")
                print("🔍 DEBUG OpenAIService: API key length: \(key.count)")
            }
        } catch {
            await MainActor.run {
                isLoadingFromAzure = false
                azureError = "Failed to load from Azure: \(error.localizedDescription)"
                print("⚠️ DEBUG OpenAIService: Azure Key Vault error: \(error.localizedDescription)")
                print("ℹ️ DEBUG OpenAIService: Falling back to keychain/manual entry")
            }
        }
    }
    
    func loadAPIKey() {
        apiKey = keychain.load(forKey: apiKeyKeychainKey) ?? ""
    }
    
    func saveAPIKey(_ key: String) {
        apiKey = key
        _ = keychain.save(key, forKey: apiKeyKeychainKey)
    }
    
    // Refresh API key from Azure (force refresh)
    func refreshFromAzure() async {
        azureKeyVault.clearCache()
        await loadAPIKeyFromAzure()
    }
    
    // Check if we're using Azure Key Vault
    func isUsingAzure() -> Bool {
        return azureKeyVault.isConfigured()
    }
    
    func verifyImage(_ imageData: Data) async throws -> ImageVerificationResult {
        let base64Image = imageData.base64EncodedString()
        let dataURL = "data:image/jpeg;base64,\(base64Image)"
        
        let messages: [[String: Any]] = [
            ["role": "system", "content": "You are a precise AI that analyzes images to determine if they contain homework content. Always respond with valid JSON only."],
            ["role": "user", "content": [
                ["type": "text", "text": "Analyze this image to determine if it contains homework content. Respond with JSON: {\"isValidHomework\": true/false, \"confidence\": 0.0-1.0, \"subject\": \"Math/Science/English/etc\", \"readabilityScore\": 0.0-1.0}"],
                ["type": "image_url", "image_url": ["url": dataURL]]
            ]]
        ]
        
        let body: [String: Any] = [
            "model": "gpt-4o",
            "messages": messages,
            "max_tokens": 500,
            "temperature": 0.0,
            "response_format": ["type": "json_object"]
        ]
        
        let result = try await makeRequest(endpoint: "/chat/completions", body: body)
        
        if let choices = result["choices"] as? [[String: Any]],
           let message = choices.first?["message"] as? [String: Any],
           let content = message["content"] as? String,
           let jsonData = content.data(using: .utf8),
           let verification = try? JSONDecoder().decode(ImageVerificationResult.self, from: jsonData) {
            return verification
        }
        
        return ImageVerificationResult(isValidHomework: true, confidence: 0.7, subject: "Math", readabilityScore: 0.8)
    }
    
    func analyzeProblem(imageData: Data?, problemText: String?, userGradeLevel: String) async throws -> ProblemAnalysis {
        print("🔍 DEBUG OpenAIService.analyzeProblem:")
        print("   Image data provided: \(imageData != nil)")
        print("   Problem text provided: \(problemText != nil)")
        print("   User grade level: \(userGradeLevel)")
        print("   API key available: \(!apiKey.isEmpty)")
        print("   API key length: \(apiKey.count)")
        let systemPrompt = """
        You are "Homework Mentor" — a precise and patient AI tutor that helps students solve their exact homework questions step by step.  
        - Focus ONLY on the given problem or image, not general education.  
        - Identify and restate all numbers and units exactly as written (say "unclear" if not visible).  
        - Use 3–5 short steps with clear logic and a single correct answer.  
        - Always output valid JSON with keys: subject, difficulty, steps (array of {question, explanation, options[], correctAnswer}), and finalAnswer.  
        - Never include extra prose outside the JSON object.
        
        AGE-APPROPRIATE LANGUAGE for \(userGradeLevel):
        
        Elementary (K-5):
        - Use simple words and concrete examples
        - Instead of formulas, show step-by-step addition/subtraction
        - Example: "length + length + width + width" NOT "2 × (length + width)"
        - Use visual language: "all four sides", "count each one", "add together"
        - Explanations should be like talking to a 10-year-old
        
        Middle School (6-8):
        - Can introduce basic formulas with explanations
        - Show both formula AND what it means in simple terms
        - Use more formal math language but keep it clear
        
        High School (9-12):
        - Use standard mathematical notation and formulas
        - Can use algebraic expressions and abstract concepts
        - Professional mathematical language is appropriate
        """
        
        let userPrompt = """
        CRITICAL: Solve ALL problems on this homework sheet. Do not stop until every problem is addressed.

        STEP 1 - COUNT THE PROBLEMS:
        - Look at the entire homework sheet carefully
        - Count how many separate problems, questions, or exercises are visible
        - Note problem numbers if present (Problem 1, Problem 2, #1, #2, etc.)
        
        STEP 2 - SOLVE EACH PROBLEM COMPLETELY:
        - For EACH problem on the sheet, create 3–5 guided steps
        - Identify and restate ALL numbers, units, and data (e.g., 4 in, 6 ft, 12 units)
        - NEVER guess or assume numbers not shown. If unclear, say "unclear"
        - Each problem must have its own set of steps leading to its final answer

        STEP 3 - VERIFY COMPLETENESS:
        - Before finishing, count your step groups
        - Ensure you have steps for EVERY problem visible on the sheet
        - If you see 5 problems, you must create steps for all 5 problems
        - DO NOT finish until ALL problems are solved

        FORMAT RULES:
        Respond in JSON with this exact structure:
        {
          "subject": "Math / Science / English / etc.",
          "difficulty": "easy / medium / hard",
          "steps": [
            {
              "question": "Problem 1: [Identify the first problem and what it asks]",
              "explanation": "What we need to find for Problem 1",
              "options": ["Option A", "Option B", "Option C", "Option D"],
              "correctAnswer": "The exact correct option text"
            },
            {
              "question": "Problem 1: [Next step for solving Problem 1]",
              "explanation": "How to approach this step",
              "options": ["Option A", "Option B", "Option C", "Option D"],
              "correctAnswer": "The exact correct option text"
            },
            ... (3-5 steps for Problem 1)
            {
              "question": "Problem 2: [Identify the second problem]",
              "explanation": "What we need to find for Problem 2",
              "options": ["Option A", "Option B", "Option C", "Option D"],
              "correctAnswer": "The exact correct option text"
            },
            ... (3-5 steps for Problem 2)
            ... (continue for ALL problems on the sheet)
          ],
          "finalAnswer": "Summary: Problem 1 = [answer], Problem 2 = [answer], Problem 3 = [answer], etc."
        }

        GUIDING STYLE:
        - Use 3–5 short, targeted steps per problem
        - Label each step with which problem it's solving (e.g., "Problem 1:", "Problem 2:")
        - Each question should build toward that problem's answer
        - Include multiple choice options that make sense, but only one is fully correct
        - Do NOT reveal the correct answer inside the question or explanation text — only in "correctAnswer"
        - For word problems: identify key facts, convert them into equations, solve step by step

        SUBJECT BEHAVIOR:
        - Math: show equations, calculate step by step, include units
        - Science: identify data, explain reasoning, conclude clearly
        - English/Reading: identify context clues, grammar rules, or main idea
        - History/Social Studies: identify factual events, names, or causes/effects clearly

        MANDATORY: Create steps for EVERY problem visible on the homework sheet. Count them and verify completeness before responding.
        """
        
        var messages: [[String: Any]] = [
            ["role": "system", "content": systemPrompt]
        ]
        
        if let imageData = imageData {
            let base64Image = imageData.base64EncodedString()
            let dataURL = "data:image/jpeg;base64,\(base64Image)"
            
            var contentArray: [[String: Any]] = [
                ["type": "text", "text": userPrompt]
            ]
            
            if let text = problemText {
                contentArray.append(["type": "text", "text": "Additional context: \(text)"])
            }
            
            contentArray.append(["type": "image_url", "image_url": ["url": dataURL]])
            
            messages.append([
                "role": "user",
                "content": contentArray
            ])
        } else if let text = problemText {
            messages.append([
                "role": "user",
                "content": "\(userPrompt)\n\nProblem: \(text)"
            ])
        }
        
        let body: [String: Any] = [
            "model": "gpt-4o",
            "messages": messages,
            "max_tokens": 4000,
            "temperature": 0.2,
            "response_format": ["type": "json_object"]
        ]
        
        print("🔍 DEBUG OpenAIService: Making request to OpenAI API...")
        let result = try await makeRequest(endpoint: "/chat/completions", body: body)
        print("🔍 DEBUG OpenAIService: Received response from OpenAI")
        
        if let choices = result["choices"] as? [[String: Any]],
           let message = choices.first?["message"] as? [String: Any],
           let content = message["content"] as? String {
            
            print("🔍 DEBUG OpenAIService: Response content length: \(content.count)")
            print("🔍 DEBUG OpenAIService: Response content preview: \(String(content.prefix(200)))...")
            
            if let jsonData = content.data(using: .utf8),
               let analysis = try? JSONDecoder().decode(ProblemAnalysis.self, from: jsonData) {
                print("🔍 DEBUG OpenAIService: Successfully parsed analysis:")
                print("   Subject: \(analysis.subject)")
                print("   Difficulty: \(analysis.difficulty)")
                print("   Number of steps: \(analysis.steps.count)")
                return analysis
            } else {
                print("❌ DEBUG OpenAIService: Failed to parse JSON response")
                print("❌ DEBUG OpenAIService: Raw content: \(content)")
            }
        } else {
            print("❌ DEBUG OpenAIService: Invalid response structure")
            print("❌ DEBUG OpenAIService: Raw result: \(result)")
        }
        
        throw NSError(domain: "OpenAIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])
    }
    
    func generateHint(for step: GuidanceStep, problemContext: String, userGradeLevel: String) async throws -> String {
        let messages: [[String: Any]] = [
            ["role": "system", "content": """
            You are "Homework Mentor" — a precise and patient AI tutor that helps students solve their exact homework questions step by step.
            Provide a subtle hint without giving away the answer. Use age-appropriate language and examples for \(userGradeLevel).
            
            CRITICAL AGE-APPROPRIATE GUIDANCE:
            
            For Elementary Students (K-5):
            - Use concrete, visual examples instead of abstract formulas
            - Break complex concepts into simple repeated additions
            - Example: Instead of "2 × (length + width)", say "Add all four sides: length + length + width + width"
            - Use drawings in words: "Imagine the rectangle has 2 long sides and 2 short sides"
            - Show actual numbers without revealing the final answer: "If the sides are 5 and 3, add: 5 + 5 + 3 + 3"
            - Use everyday language: "count", "add together", "put side by side"
            
            For Middle School (6-8):
            - Can introduce simple formulas with explanations
            - Show both the formula AND the concrete breakdown
            - Example: "Perimeter = 2 × length + 2 × width, which means adding the two long sides and two short sides"
            - Use visual representations when helpful
            
            For High School (9-12):
            - Can use standard mathematical notation and formulas
            - Provide algebraic or formula-based hints
            - Example: "Use the formula P = 2(l + w) or 2l + 2w"
            
            IMPORTANT:
            - NEVER provide the final numerical answer
            - Show the pattern or method, not the solution
            - Guide thinking with questions: "What are we adding together?"
            - Use specific numbers from the problem to illustrate WITHOUT solving completely
            
            Focus on guiding the student's thinking, not solving for them.
            """],
            ["role": "user", "content": "Question: \(step.question)\nContext: \(problemContext)\nGrade Level: \(userGradeLevel)\n\nProvide a helpful, age-appropriate hint that shows the thinking process but doesn't give away the final answer."]
        ]
        
        let body: [String: Any] = [
            "model": "gpt-4o",
            "messages": messages,
            "max_tokens": 400,
            "temperature": 0.2
        ]
        
        let result = try await makeRequest(endpoint: "/chat/completions", body: body)
        
        if let choices = result["choices"] as? [[String: Any]],
           let message = choices.first?["message"] as? [String: Any],
           let content = message["content"] as? String {
            return content
        }
        
        return "Think about the key concepts involved in this step."
    }
    
    func generateChatResponse(messages: [ChatMessage], problemContext: String, userGradeLevel: String) async throws -> String {
        let chatMessages: [[String: Any]] = [
            ["role": "system", "content": """
            You are "Homework Mentor" — a precise and patient AI tutor that helps students solve their exact homework questions step by step.
            When students ask questions, provide direct, clear answers using age-appropriate language for \(userGradeLevel).
            
            IMPORTANT: Consider the full context:
            - The current homework problem and step they're working on
            - The available answer options
            - Their progress through the problem
            - The specific question they're asking
            
            Provide responses that:
            - Give direct, factually accurate answers
            - Explain concepts clearly and completely
            - Use age-appropriate language for \(userGradeLevel)
            - Reference the specific context of their homework
            - Are helpful and informative, not evasive
            
            Grade-level guidelines:
            - Elementary: Use simple words, give lots of encouragement, provide clear explanations
            - Middle school: Introduce more complex reasoning, be supportive and direct
            - High school: Use formal language and advanced concepts, give thorough explanations
            """]
        ] + messages.map { msg in
            ["role": msg.role.rawValue, "content": msg.content]
        }
        
        let body: [String: Any] = [
            "model": "gpt-4o",
            "messages": chatMessages,
            "max_tokens": 800,
            "temperature": 0.2
        ]
        
        let result = try await makeRequest(endpoint: "/chat/completions", body: body)
        
        if let choices = result["choices"] as? [[String: Any]],
           let message = choices.first?["message"] as? [String: Any],
           let content = message["content"] as? String {
            return content
        }
        
        throw NSError(domain: "OpenAIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get response"])
    }
    
    private func makeRequest(endpoint: String, body: [String: Any]) async throws -> [String: Any] {
        guard !apiKey.isEmpty else {
            throw NSError(domain: "OpenAIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "API key not set. Please add your OpenAI API key in Settings."])
        }
        
        let url = URL(string: baseURL + endpoint)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "OpenAIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No response from server"])
        }
        
        guard httpResponse.statusCode == 200 else {
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = json["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw NSError(domain: "OpenAIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "OpenAI API Error: \(message)"])
            }
            throw NSError(domain: "OpenAIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "API request failed with status code \(httpResponse.statusCode)"])
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(domain: "OpenAIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
        }
        
        return json
    }
}

struct ImageVerificationResult: Codable {
    let isValidHomework: Bool
    let confidence: Double
    let subject: String?
    let readabilityScore: Double
}

struct ProblemAnalysis: Codable {
    let subject: String
    let difficulty: String
    let steps: [StepData]
    let finalAnswer: String?
}

struct StepData: Codable {
    let question: String
    let explanation: String
    let options: [String]
    let correctAnswer: String
}
