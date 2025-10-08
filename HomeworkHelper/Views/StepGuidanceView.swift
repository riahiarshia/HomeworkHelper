import SwiftUI

struct StepGuidanceView: View {
    let problemId: UUID
    
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var currentStepIndex = 0
    @State private var selectedAnswer: String?
    @State private var showHint = false
    @State private var hintText = ""
    @State private var isLoadingHint = false
    @State private var showFeedback = false
    @State private var feedbackMessage = ""
    @State private var showCompletion = false
    @State private var showChat = false
    @State private var studentQuestion = ""
    @State private var showQuestionArea = false
    @State private var isSubmittingQuestion = false
    @State private var debugInfo = ""
    @State private var showCompletionView = false
    
    // New tutor flow states
    @State private var showOptions = false
    @State private var shuffledOptions: [String] = []
    @State private var attemptCount = 0
    @State private var hasShownInitialHint = false
    
    private var steps: [GuidanceStep] {
        dataManager.steps[problemId.uuidString]?.sorted(by: { $0.stepNumber < $1.stepNumber }) ?? []
    }
    
    private var currentStep: GuidanceStep? {
        guard currentStepIndex < steps.count else { return nil }
        return steps[currentStepIndex]
    }
    
    private var problem: HomeworkProblem? {
        dataManager.problems.first(where: { $0.id == problemId })
    }
    
    var body: some View {
        Group {
            if steps.isEmpty {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading homework steps...")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    print("🔍 DEBUG StepGuidanceView onAppear:")
                    print("   Problem ID: \(problemId.uuidString)")
                    print("   Total steps in DataManager: \(dataManager.steps.count)")
                    print("   Steps for this problem: \(dataManager.steps[problemId.uuidString]?.count ?? 0)")
                    print("   All problem IDs: \(dataManager.steps.keys.joined(separator: ", "))")
                    
                    // Check if steps are still loading after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        print("🔍 DEBUG StepGuidanceView after 2 seconds:")
                        print("   Steps still empty: \(steps.isEmpty)")
                        print("   DataManager steps count: \(dataManager.steps[problemId.uuidString]?.count ?? 0)")
                        
                        if steps.isEmpty {
                            print("⚠️ WARNING: Steps still not loaded after 2 seconds!")
                            print("   This indicates a problem with step generation or storage")
                        }
                    }
                }
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        if let step = currentStep {
                            progressIndicator
                            
                            stepContent(step)
                            
                            // Show hint first (before options)
                            if !hasShownInitialHint || (attemptCount > 0 && !showOptions) {
                                if isLoadingHint {
                                    VStack(spacing: 12) {
                                        ProgressView()
                                        Text("Generating hint...")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.orange.opacity(0.1))
                                    .cornerRadius(12)
                                } else if !hintText.isEmpty {
                                    tutorHintView
                                }
                            }
                            
                            // Show Continue button to reveal options (or after wrong answer)
                            if !showOptions && hasShownInitialHint && !isLoadingHint {
                                Button {
                                    showMultipleChoice(step)
                                } label: {
                                    Text("Continue")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .cornerRadius(12)
                                }
                            }
                            
                            // Show options after Continue is pressed
                            if showOptions {
                                optionsView(step)
                            }
                            
                            questionArea
                            
                            // Only show skip button, not hint button (hint is automatic)
                            if showOptions {
                                Button {
                                    skipStep(step)
                                } label: {
                                    HStack {
                                        Image(systemName: "forward.fill")
                                        Text("Skip This Step")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                            }
                        } else if showCompletion {
                            completionView
                        }
                    }
                    .padding()
                }
                .onAppear {
                    // Load initial hint when step appears
                    if let step = currentStep, !hasShownInitialHint {
                        Task {
                            await loadInitialHint(step)
                        }
                    }
                }
            }
        }
        .navigationTitle("Problem \(problem?.id.uuidString.prefix(8) ?? "Unknown") - Step \(currentStepIndex + 1) of \(steps.count)")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    goToPreviousStep()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text(currentStepIndex > 0 ? "Previous" : "Home")
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showChat = true
                } label: {
                    Image(systemName: "message.fill")
                }
            }
        }
        .sheet(isPresented: $showChat) {
            ChatView(problemId: problemId)
        }
        .sheet(isPresented: $showCompletionView) {
            VStack(spacing: 20) {
                Text("🎉 Congratulations! 🎉")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Homework Complete!")
                    .font(.title2)
                if let problem = problem {
                    Text("You've completed your \(problem.subject ?? "homework")!")
                        .font(.body)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 12) {
                    Button("Try This Homework Again") {
                        showCompletionView = false
                        restartCurrentHomework()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button("Start New Homework") {
                        showCompletionView = false
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button("Back to Home") {
                        showCompletionView = false
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding()
        }
        .alert("Feedback", isPresented: $showFeedback) {
            Button("Continue") {
                if feedbackMessage.contains("Correct") || feedbackMessage.contains("skipped") {
                    advanceToNextStep()
                }
            }
        } message: {
            Text(feedbackMessage)
        }
    }
    
    private var progressIndicator: some View {
        VStack(spacing: 8) {
            ProgressView(value: Double(currentStepIndex), total: Double(steps.count))
            
            Text("Step \(currentStepIndex + 1) of \(steps.count)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private func stepContent(_ step: GuidanceStep) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(step.question)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(step.explanation)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func optionsView(_ step: GuidanceStep) -> some View {
        VStack(spacing: 12) {
            // Use shuffled options instead of original order
            let optionsToShow = shuffledOptions.isEmpty ? step.options : shuffledOptions
            
            ForEach(optionsToShow, id: \.self) { option in
                Button {
                    handleAnswerSelection(option, step: step)
                } label: {
                    HStack {
                        Text(option)
                            .foregroundColor(.primary)
                        Spacer()
                        if selectedAnswer == option {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(selectedAnswer == option ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedAnswer == option ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                            )
                    )
                }
            }
        }
    }
    
    private func actionButtons(_ step: GuidanceStep) -> some View {
        VStack(spacing: 12) {
            if let answer = selectedAnswer {
                Button {
                    checkAnswer(answer, step: step)
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            
            HStack(spacing: 12) {
                Button {
                    Task {
                        await loadHint(step)
                    }
                } label: {
                    HStack {
                        if isLoadingHint {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "lightbulb.fill")
                            Text("Need a hint?")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(isLoadingHint)
                
                Button {
                    skipStep(step)
                } label: {
                    HStack {
                        Image(systemName: "forward.fill")
                        Text("Skip")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
        }
    }
    
    private var questionArea: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                showQuestionArea.toggle()
            } label: {
                HStack {
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundColor(.blue)
                    Text("Ask a Question")
                        .font(.headline)
                        .foregroundColor(.blue)
                    Spacer()
                    Image(systemName: showQuestionArea ? "chevron.up" : "chevron.down")
                        .foregroundColor(.blue)
                }
            }
            
            if showQuestionArea {
                VStack(spacing: 12) {
                    TextEditor(text: $studentQuestion)
                        .frame(height: 80)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    
                    Button {
                        Task {
                            await submitQuestion()
                        }
                    } label: {
                        HStack {
                            if isSubmittingQuestion {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "paperplane.fill")
                            }
                            Text("Ask Question")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(studentQuestion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(studentQuestion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSubmittingQuestion)
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var hintView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.orange)
                Text("Hint")
                    .font(.headline)
            }
            
            Text(hintText)
                .font(.body)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(10)
    }
    
    private var tutorHintView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                Text("💡 Think About This...")
                    .font(.headline)
                    .foregroundColor(.orange)
            }
            
            Text(hintText)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
            
            if attemptCount > 0 {
                Text("Attempt \(attemptCount + 1)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 2)
                )
        )
    }
    
    private var completionView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Problem Completed!")
                .font(.title)
                .fontWeight(.bold)
            
            if let problem = problem, let points = problem.pointsAwarded {
                Text("You earned \(points) points!")
                    .font(.title3)
                
                if problem.skippedSteps > 0 {
                    Text("(\(problem.skippedSteps) steps skipped)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Back to Home")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
    
    private func checkAnswer(_ answer: String, step: GuidanceStep) {
        var updatedStep = step
        updatedStep.userAnswer = answer
        updatedStep.isCompleted = true
        
        // Use AI to verify the answer for more accurate checking
        Task {
            await verifyAnswerWithAI(answer: answer, step: step, updatedStep: updatedStep)
        }
    }
    
    private func verifyAnswerWithAI(answer: String, step: GuidanceStep, updatedStep: GuidanceStep) async {
        // First do simple string comparison - most reliable method
        let trimmedAnswer = answer.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCorrectAnswer = step.correctAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
        
        await MainActor.run {
            print("🔍 DEBUG: Comparing answers:")
            print("   Student answer: '\(trimmedAnswer)'")
            print("   Correct answer: '\(trimmedCorrectAnswer)'")
            print("   Match: \(trimmedAnswer == trimmedCorrectAnswer)")
            
            if trimmedAnswer == trimmedCorrectAnswer {
                // Exact match - definitely correct
                feedbackMessage = "Correct! \(step.explanation)"
                dataManager.updateStep(updatedStep, for: problemId)
                
                if var problem = problem {
                    problem.completedSteps += 1
                    dataManager.updateProblem(problem)
                }
            } else {
                // Use AI verification for more complex cases
                Task {
                    await performAIVerification(answer: answer, step: step, updatedStep: updatedStep)
                }
                return
            }
            
            showFeedback = true
        }
    }
    
    private func performAIVerification(answer: String, step: GuidanceStep, updatedStep: GuidanceStep) async {
        do {
            let userGradeLevel = dataManager.currentUser?.getGradeLevel() ?? "elementary"
            let problemContext = problem?.problemText ?? "homework problem"
            
            // Enhanced verification prompt for 100% accuracy
            let verificationPrompt = """
            CRITICAL: You are verifying a student's homework answer. Accuracy is ESSENTIAL to prevent misleading the student.
            
            Question: \(step.question)
            Expected Correct Answer: \(step.correctAnswer)
            Student's Selected Answer: \(answer)
            All Available Options: \(step.options.joined(separator: ", "))
            
            VERIFICATION REQUIREMENTS:
            1. Check if the student's answer is mathematically/factually correct
            2. Consider equivalent expressions (e.g., "2+3" = "5", "half" = "0.5", "subtract 4" = "minus 4")
            3. Be strict about factual accuracy - if it's wrong, it's wrong
            4. Consider the student's grade level: \(userGradeLevel)
            
            EXAMPLES OF ACCEPTABLE VARIATIONS:
            - Mathematical: "5" = "five" = "2+3" = "10/2"
            - Operations: "add 3" = "plus 3" = "3 more"
            - Fractions: "1/2" = "half" = "0.5"
            
            RESPOND WITH EXACTLY ONE WORD:
            - "CORRECT" if the answer is right (including equivalent forms)
            - "INCORRECT" if the answer is wrong or misleading
            
            The student's education depends on your accuracy. Be thorough but fair.
            """
            
            let verificationResponse = try await BackendAPIService.shared.generateChatResponse(
                messages: [ChatMessage(problemId: problemId, role: .user, content: verificationPrompt)],
                problemContext: problemContext,
                userGradeLevel: userGradeLevel
            )
            
            let trimmedResponse = verificationResponse.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            let isCorrect = trimmedResponse.contains("CORRECT") && !trimmedResponse.contains("INCORRECT")
            
            print("🤖 AI Response: '\(trimmedResponse)'")
            print("🎯 Is Correct: \(isCorrect)")
            
            await MainActor.run {
                if isCorrect {
                    feedbackMessage = "Correct! \(step.explanation)"
                    dataManager.updateStep(updatedStep, for: problemId)
                    
                    if var problem = problem {
                        problem.completedSteps += 1
                        dataManager.updateProblem(problem)
                    }
                    
                    // User will advance manually by clicking "Continue" in the feedback alert
                } else {
                    feedbackMessage = "Not quite right. Try thinking about: \(step.explanation)"
                }
                
                showFeedback = true
            }
            
        } catch {
            // Final fallback - be more lenient with string matching
            await MainActor.run {
                let trimmedAnswer = answer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                let trimmedCorrectAnswer = step.correctAnswer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                
                let answerWords = Set(trimmedAnswer.split(separator: " ").map { String($0).trimmingCharacters(in: .punctuationCharacters) }.filter { !$0.isEmpty })
                let correctWords = Set(trimmedCorrectAnswer.split(separator: " ").map { String($0).trimmingCharacters(in: .punctuationCharacters) }.filter { !$0.isEmpty })
                
                // If more than 70% of words match, consider it correct
                let intersection = answerWords.intersection(correctWords)
                let matchRatio = Double(intersection.count) / Double(max(answerWords.count, correctWords.count))
                
                if matchRatio >= 0.7 {
                    feedbackMessage = "Correct! \(step.explanation)"
                    dataManager.updateStep(updatedStep, for: problemId)
                    
                    if var problem = problem {
                        problem.completedSteps += 1
                        dataManager.updateProblem(problem)
                    }
                    
                    // User will advance manually by clicking "Continue" in the feedback alert
                } else {
                    feedbackMessage = "Not quite right. Try thinking about: \(step.explanation)"
                }
                
                showFeedback = true
            }
        }
    }
    
    private func skipStep(_ step: GuidanceStep) {
        var updatedStep = step
        updatedStep.isSkipped = true
        updatedStep.isCompleted = true
        dataManager.updateStep(updatedStep, for: problemId)
        
        if var problem = problem {
            problem.completedSteps += 1
            problem.skippedSteps += 1
            dataManager.updateProblem(problem)
        }
        
        // Show feedback that step was skipped - user will advance manually
        feedbackMessage = "Step skipped. Click Continue to move to the next step."
        showFeedback = true
    }
    
    private func moveToNextStep() {
        if currentStepIndex < steps.count - 1 {
            currentStepIndex += 1
            selectedAnswer = nil
            showHint = false
        } else {
            completeProblem()
        }
    }
    
    private func goToPreviousStep() {
        if currentStepIndex > 0 {
            // Go back to previous step
            currentStepIndex -= 1
            selectedAnswer = nil
            showHint = false
            feedbackMessage = ""
            showFeedback = false
        } else {
            // At first step, go back to home
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func completeProblem() {
        guard var problem = problem else { return }
        
        let skippedSteps = problem.skippedSteps
        let basePoints = 10
        let pointsEarned = skippedSteps > 0 ? 5 : basePoints
        
        problem.status = .completed
        problem.completedAt = Date()
        problem.pointsAwarded = pointsEarned
        dataManager.updateProblem(problem)
        
        dataManager.updateUserPoints(pointsEarned)
        
        if let subject = problem.subject {
            dataManager.updateProgress(subject: subject, points: pointsEarned)
        }
        
        showCompletionView = true
    }
    
    private func restartCurrentHomework() {
        // Reset all step progress
        currentStepIndex = 0
        selectedAnswer = nil
        showHint = false
        showFeedback = false
        feedbackMessage = ""
        
        // Reset problem status
        if var problem = problem {
            problem.status = .inProgress
            problem.completedSteps = 0
            problem.skippedSteps = 0
            problem.completedAt = nil
            problem.pointsAwarded = nil
            dataManager.updateProblem(problem)
        }
        
        // Reset all steps for this problem
        if let steps = dataManager.steps[problemId.uuidString] {
            for var step in steps {
                step.isCompleted = false
                step.isSkipped = false
                step.userAnswer = nil
                step.hintsUsed = 0
                dataManager.updateStep(step, for: problemId)
            }
        }
    }
    
    // MARK: - New Tutor Flow Functions
    
    private func loadInitialHint(_ step: GuidanceStep) async {
        isLoadingHint = true
        
        do {
            let problemContext = buildProblemContext()
            let userGradeLevel = dataManager.currentUser?.getGradeLevel() ?? "elementary"
            
            hintText = try await BackendAPIService.shared.generateHint(for: step, problemContext: problemContext, userGradeLevel: userGradeLevel)
            hasShownInitialHint = true
            
            var updatedStep = step
            updatedStep.hintsUsed += 1
            dataManager.updateStep(updatedStep, for: problemId)
        } catch {
            hintText = "Think about what the question is asking. Read it carefully and consider what you already know about this topic."
            hasShownInitialHint = true
        }
        
        isLoadingHint = false
    }
    
    private func showMultipleChoice(_ step: GuidanceStep) {
        // Shuffle options on first display or after wrong answer
        shuffledOptions = step.options.shuffled()
        showOptions = true
        selectedAnswer = nil
    }
    
    private func handleAnswerSelection(_ answer: String, step: GuidanceStep) {
        selectedAnswer = answer
        
        // Check if answer is correct
        if answer == step.correctAnswer {
            // Correct answer!
            feedbackMessage = "✅ Correct! \(step.explanation)"
            showFeedback = true
            
            var updatedStep = step
            updatedStep.userAnswer = answer
            updatedStep.isCompleted = true
            dataManager.updateStep(updatedStep, for: problemId)
            
            if var problem = problem {
                problem.completedSteps += 1
                dataManager.updateProblem(problem)
            }
        } else {
            // Wrong answer - show new hint
            attemptCount += 1
            showOptions = false
            selectedAnswer = nil
            
            // Generate new hint with different approach
            Task {
                await loadHintAfterWrongAnswer(step)
            }
        }
    }
    
    private func loadHintAfterWrongAnswer(_ step: GuidanceStep) async {
        isLoadingHint = true
        
        do {
            let problemContext = buildProblemContext()
            let userGradeLevel = dataManager.currentUser?.getGradeLevel() ?? "elementary"
            
            // Request a different hint approach
            hintText = try await BackendAPIService.shared.generateHint(for: step, problemContext: problemContext + "\n\nNote: Student attempted but got it wrong. Provide a DIFFERENT hint with a new approach or perspective.", userGradeLevel: userGradeLevel)
            
            var updatedStep = step
            updatedStep.hintsUsed += 1
            dataManager.updateStep(updatedStep, for: problemId)
        } catch {
            hintText = "Let's try thinking about it differently. What is the main concept in this question?"
        }
        
        isLoadingHint = false
    }
    
    private func buildProblemContext() -> String {
        var contextParts: [String] = []
        
        if let prob = problem {
            // Add subject
            if let subject = prob.subject {
                contextParts.append("Subject: \(subject)")
            }
            
            // Add problem text
            if let text = prob.problemText {
                contextParts.append("Problem: \(text)")
            }
            
            // Add all previous steps for context
            let completedSteps = steps.prefix(currentStepIndex)
            if !completedSteps.isEmpty {
                let stepsContext = completedSteps.map { s in
                    "Step \(s.stepNumber): \(s.question) → Answer: \(s.correctAnswer)"
                }.joined(separator: "\n")
                contextParts.append("Previous steps:\n\(stepsContext)")
            }
        }
        
        return contextParts.isEmpty ? "homework problem" : contextParts.joined(separator: "\n\n")
    }
    
    private func advanceToNextStep() {
        if currentStepIndex < steps.count - 1 {
            // Move to next step
            currentStepIndex += 1
            
            // Reset tutor flow states for new step
            showOptions = false
            shuffledOptions = []
            selectedAnswer = nil
            hasShownInitialHint = false
            attemptCount = 0
            hintText = ""
            showHint = false
            feedbackMessage = ""
            showFeedback = false
            
            // Load initial hint for new step
            if let step = currentStep {
                Task {
                    await loadInitialHint(step)
                }
            }
        } else {
            // All steps completed
            completeProblem()
        }
    }
    
    private func loadHint(_ step: GuidanceStep) async {
        isLoadingHint = true
        
        do {
            let problemContext = buildProblemContext()
            let userGradeLevel = dataManager.currentUser?.getGradeLevel() ?? "elementary"
            
            hintText = try await BackendAPIService.shared.generateHint(for: step, problemContext: problemContext, userGradeLevel: userGradeLevel)
            showHint = true
            
            var updatedStep = step
            updatedStep.hintsUsed += 1
            dataManager.updateStep(updatedStep, for: problemId)
        } catch {
            hintText = "Unable to generate hint. Think about the key concepts."
            showHint = true
        }
        
        isLoadingHint = false
    }
    
    private func submitQuestion() async {
        guard !studentQuestion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isSubmittingQuestion = true
        
        do {
            let userGradeLevel = dataManager.currentUser?.getGradeLevel() ?? "elementary"
            let problemContext = problem?.problemText ?? "homework problem"
            
            // Build comprehensive context for the AI
            let currentStepContext = if let step = currentStep {
                """
                Current Step: \(step.question)
                Available Options: \(step.options.joined(separator: ", "))
                Correct Answer: \(step.correctAnswer)
                Explanation: \(step.explanation)
                """
            } else {
                "No current step available"
            }
            
            let problemProgress = if let problem = problem {
                """
                Problem: \(problem.subject ?? "Unknown") - Step \(currentStepIndex + 1) of \(steps.count)
                Completed Steps: \(problem.completedSteps)
                """
            } else {
                "Problem information not available"
            }
            
            // Create a context-rich question message
            let contextualQuestion = """
            CONTEXT:
            \(problemProgress)
            \(currentStepContext)
            
            STUDENT QUESTION: \(studentQuestion)
            
            Please provide a direct, helpful answer to the student's question. Explain the concept clearly and completely. Be encouraging and age-appropriate for \(userGradeLevel). Give them the information they need to understand and solve the problem.
            """
            
            // Create a temporary chat message for the question
            let userMessage = ChatMessage(
                problemId: problemId,
                role: .user,
                content: contextualQuestion
            )
            dataManager.addMessage(userMessage, for: problemId)
            
            // Get AI response with enhanced context
            let response = try await BackendAPIService.shared.generateChatResponse(
                messages: dataManager.messages[problemId.uuidString] ?? [],
                problemContext: problemContext,
                userGradeLevel: userGradeLevel
            )
            
            let assistantMessage = ChatMessage(
                problemId: problemId,
                role: .assistant,
                content: response
            )
            dataManager.addMessage(assistantMessage, for: problemId)
            
            // Clear the question and close the area
            studentQuestion = ""
            showQuestionArea = false
            
            // Show the response in an alert
            feedbackMessage = response
            showFeedback = true
            
        } catch {
            feedbackMessage = "Sorry, I couldn't process your question. Please try again."
            showFeedback = true
        }
        
        isSubmittingQuestion = false
    }
}
