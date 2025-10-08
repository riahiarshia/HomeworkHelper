import SwiftUI
import PhotosUI
import AudioToolbox
import AVFoundation
import os.log

enum TimeoutError: LocalizedError {
    case timeout
    
    var errorDescription: String? {
        switch self {
        case .timeout:
            return "Request timed out. Please check your network connection and try again."
        }
    }
}

private let logger = Logger(subsystem: "com.homeworkhelper.app", category: "HomeView")

struct HomeView: View {
    @EnvironmentObject var dataManager: DataManager
    @StateObject private var backendService = BackendAPIService.shared
    
    init() {
        logger.critical("🚨 CRITICAL DEBUG: HomeView init called!")
    }
    
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var showImageCropper = false
    @State private var tempImageForCropping: UIImage?
    @State private var pendingImageSource: ImageSource? = nil
    
    enum ImageSource {
        case camera
        case photoLibrary
    }
    @State private var isProcessing = false
    @State private var processingMessage = ""
    @State private var showImageQualityAlert = false
    @State private var imageQualityMessage = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToGuidance = false
    @State private var currentProblemId: UUID?
    @State private var showLaunchAnimation = true
    @State private var animationScale: CGFloat = 0.5
    @State private var animationOpacity: Double = 0.0
    @State private var hasShownLaunchAnimation = false
    @State private var bigBrainAnimation = false
    @State private var handTapAnimation = false
    @State private var showBigBrainText = false
    @State private var currentBrainPhrase = "BIG BRAIN!"
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 24) {
                        if isProcessing {
                            processingView
                        }
                        
                        headerView
                        
                        uploadSection
                        
                        if selectedImage != nil && !navigateToGuidance {
                            imagePreview
                        }
                    }
                    .padding()
                }
                .navigationTitle("Homework Helper")
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("home_view")
                .opacity(showLaunchAnimation ? 0.0 : 1.0)
                
                if showLaunchAnimation {
                    launchAnimationView
                }
            }
            .onAppear {
                logger.critical("🚨 CRITICAL DEBUG: HomeView onAppear called!")
                if showLaunchAnimation && !hasShownLaunchAnimation {
                    hasShownLaunchAnimation = true
                    startLaunchAnimation()
                } else {
                    showLaunchAnimation = false
                }
                // Clear any previous image when returning to home
                if navigateToGuidance {
                    selectedImage = nil
                    navigateToGuidance = false
                }
            }
            .background(
                NavigationLink(
                    destination: destinationView,
                    isActive: $navigateToGuidance,
                    label: { EmptyView() }
                )
            )
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $tempImageForCropping, sourceType: .photoLibrary, onImageSelected: { image in
                    logger.critical("🚨 CRITICAL DEBUG: Photo library onImageSelected callback - setting tempImageForCropping")
                    tempImageForCropping = image
                    selectedImage = nil
                    showImagePicker = false
                    
                    // Wait for sheet to dismiss, then show cropper
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        logger.critical("🚨 CRITICAL DEBUG: About to show ImageCropper, tempImageForCropping is nil: \(image == nil)")
                        showImageCropper = true
                    }
                })
            }
            .sheet(isPresented: $showCamera) {
                ImagePicker(image: $tempImageForCropping, sourceType: .camera, onImageSelected: { image in
                    print("📸 Image captured from camera")
                    tempImageForCropping = image
                    selectedImage = nil
                    showCamera = false
                    
                    // Wait for sheet to dismiss, then show cropper
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showImageCropper = true
                    }
                })
            }
            .sheet(isPresented: $showImageCropper) {
                ImageCropperView(image: $tempImageForCropping, onCrop: { croppedImage in
                    logger.critical("🚨 CRITICAL DEBUG: ImageCropper onCrop callback - received cropped image")
                    // Dismiss sheet first
                    showImageCropper = false
                    
                    // Clear temp image and pending source
                    tempImageForCropping = nil
                    pendingImageSource = nil
                    
                    // Wait for sheet to fully dismiss before starting analysis
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        logger.critical("🚨 CRITICAL DEBUG: Starting image analysis")
                        analyzeImageWithQualityCheck(croppedImage)
                    }
                })
                .interactiveDismissDisabled(false)
            }
            .alert("Error", isPresented: $showAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
            .alert("Image Quality Issue", isPresented: $showImageQualityAlert) {
                Button("Try Different Image") {
                    selectedImage = nil
                }
                Button("Analyze Anyway") {
                    // User wants to proceed despite quality issues
                    Task {
                        await analyzeImageIgnoringQuality()
                    }
                }
            } message: {
                Text(imageQualityMessage)
            }
        }
    }
    
    @ViewBuilder
    private var destinationView: some View {
        if let problemId = currentProblemId {
            StepGuidanceView(problemId: problemId)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            // Animated cartoon head
            ZStack {
                // Head (circle)
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [Color.yellow.opacity(0.8), Color.orange.opacity(0.6)]),
                            center: .topLeading,
                            startRadius: 20,
                            endRadius: 80
                        )
                    )
                    .frame(width: 100, height: 100)
                    .scaleEffect(bigBrainAnimation ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: bigBrainAnimation)
                
                // Eyes
                HStack(spacing: 20) {
                    // Left eye
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 15, height: 15)
                        Circle()
                            .fill(Color.black)
                            .frame(width: 8, height: 8)
                    }
                    
                    // Right eye
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 15, height: 15)
                        Circle()
                            .fill(Color.black)
                            .frame(width: 8, height: 8)
                    }
                }
                .offset(y: -15)
                
                // Mouth (smile)
                Path { path in
                    path.addArc(
                        center: CGPoint(x: 50, y: 65),
                        radius: 15,
                        startAngle: .degrees(0),
                        endAngle: .degrees(180),
                        clockwise: false
                    )
                }
                .stroke(Color.black, lineWidth: 3)
                .frame(width: 100, height: 100)
                
                // Animated hand tapping head
                Image(systemName: "hand.point.up.fill")
                    .font(.system(size: 25))
                    .foregroundColor(.brown)
                    .offset(x: 35, y: -35)
                    .rotationEffect(.degrees(handTapAnimation ? -20 : 0))
                    .scaleEffect(handTapAnimation ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: handTapAnimation)
                
                // "BIG BRAIN" text bubble
                if showBigBrainText {
                    VStack {
                        Text(currentBrainPhrase)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white)
                                    .shadow(radius: 5)
                            )
                            .scaleEffect(showBigBrainText ? 1.0 : 0.1)
                            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showBigBrainText)
                        
                        // Speech bubble tail
                        Triangle()
                            .fill(Color.white)
                            .frame(width: 15, height: 10)
                            .offset(y: -5)
                    }
                    .offset(x: 0, y: -80)
                }
            }
            .onTapGesture {
                startBigBrainAnimation()
            }
            .onAppear {
                // Auto-trigger animation after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    startBigBrainAnimation()
                }
            }
            
            Text("Learn by Solving")
                .font(.title2)
                .foregroundColor(.secondary)
                .accessibilityIdentifier("learn_by_solving")
            
            // Tagline
            VStack(spacing: 4) {
                Text("Your AI Tutor for Step-by-Step Learning")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text("No Cheating - Real Learning")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            if let user = dataManager.currentUser {
                HStack(spacing: 16) {
                    Label("\(user.points)", systemImage: "star.fill")
                        .foregroundColor(.orange)
                    Label("\(user.streak) day streak", systemImage: "flame.fill")
                        .foregroundColor(.red)
                }
                .font(.headline)
            }
        }
        .padding(.vertical)
    }
    
    private var uploadSection: some View {
        VStack(spacing: 12) {
            Text("Upload Your Homework")
                .font(.headline)
            
            Text("Take a photo or select from your library - we'll analyze it automatically!")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            HStack(spacing: 12) {
                Button {
                    logger.critical("🚨 CRITICAL DEBUG: Camera button tapped!")
                    pendingImageSource = .camera
                    showCamera = true
                } label: {
                    Label("Camera", systemImage: "camera.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .accessibilityIdentifier("camera_button")
                .disabled(isProcessing)
                
                Button {
                    logger.critical("🚨 CRITICAL DEBUG: Photo Library button tapped!")
                    pendingImageSource = .photoLibrary
                    showImagePicker = true
                } label: {
                    Label("Photo Library", systemImage: "photo.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .accessibilityIdentifier("photo_library_button")
                .disabled(isProcessing)
            }
        }
    }
    
    // MARK: - Network Reachability
    
    private func checkNetworkReachability() async -> Bool {
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
            print("❌ DEBUG HomeView: Network reachability check failed: \(error)")
            return false
        }
    }
    
    // MARK: - Timeout Wrapper
    
    private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        return try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                return try await operation()
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw TimeoutError.timeout
            }
            
            guard let result = try await group.next() else {
                throw TimeoutError.timeout
            }
            
            group.cancelAll()
            return result
        }
    }
    
    private var imagePreview: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .cornerRadius(10)
                
                Button("Remove Image") {
                    selectedImage = nil
                    isProcessing = false
                }
                .foregroundColor(.red)
                .disabled(isProcessing)
            }
        }
    }
    
    private var processingView: some View {
        VStack(spacing: 20) {
            // Animated gradient circle with rotating icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple, .pink, .orange]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .scaleEffect(1.0 + sin(Date().timeIntervalSince1970 * 2) * 0.1)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: Date())
                
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(Date().timeIntervalSince1970 * 30))
                    .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: Date())
            }
            
            VStack(spacing: 8) {
                Text(backendService.progressMessage.isEmpty ? processingMessage : backendService.progressMessage)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .transition(.opacity.combined(with: .scale))
                
                Text("This may take a few seconds while we analyze your image...")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            
            // Animated progress dots
            HStack(spacing: 8) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                        .scaleEffect(1.0 + sin(Date().timeIntervalSince1970 * 2 + Double(index) * 0.5) * 0.5)
                        .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true).delay(Double(index) * 0.2), value: Date())
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
        )
        .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
    }
    
    private var launchAnimationView: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Main logo/icon with animation
                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .scaleEffect(animationScale)
                    .opacity(animationOpacity)
                
                // Animated text
                VStack(spacing: 10) {
                    Text("Homework Made Easier")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .opacity(animationOpacity)
                    
                    Text("Without Cheating")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.9))
                        .opacity(animationOpacity)
                }
                
                // Fireworks animation
                HStack(spacing: 20) {
                    ForEach(0..<5) { index in
                        Image(systemName: "sparkles")
                            .font(.title)
                            .foregroundColor(.yellow)
                            .opacity(animationOpacity)
                            .scaleEffect(animationScale)
                            .rotationEffect(.degrees(Double(index) * 72))
                    }
                }
            }
        }
    }
    
    private func startBigBrainAnimation() {
        // Speak "BIG BRAIN" aloud
        speakBigBrain()
        
        // Play additional sound effect
        AudioServicesPlaySystemSound(1057) // Tweet sound for emphasis
        
        // Animate hand tapping
        withAnimation(.easeInOut(duration: 0.2)) {
            handTapAnimation = true
        }
        
        // Animate head scaling
        withAnimation(.easeInOut(duration: 0.3)) {
            bigBrainAnimation = true
        }
        
        // Show text bubble
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                showBigBrainText = true
            }
        }
        
        // Reset animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeInOut(duration: 0.2)) {
                handTapAnimation = false
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.3)) {
                bigBrainAnimation = false
            }
        }
        
        // Hide text bubble
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showBigBrainText = false
            }
        }
    }
    
    private func speakBigBrain() {
        // Stop any current speech
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
                    
        // Random phrases for variety
        let phrases = [
            "BIG BRAIN!",
            "Big brain time!",
            "Smart thinking!",
            "Genius mode activated!",
            "Brain power!"
        ]
        
        let randomPhrase = phrases.randomElement() ?? "BIG BRAIN!"
        
        // Update the displayed text to match what's being spoken
        currentBrainPhrase = randomPhrase
        
        // Create speech utterance
        let utterance = AVSpeechUtterance(string: randomPhrase)
        
        // Configure speech parameters for fun effect
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5 // Slightly slower for emphasis
        utterance.pitchMultiplier = 1.2 // Higher pitch for excitement
        utterance.volume = 0.8
        
        // Speak it!
        speechSynthesizer.speak(utterance)
    }
    
    private func startLaunchAnimation() {
        // Play celebration sound effect
        AudioServicesPlaySystemSound(1016) // Fanfare sound
        
        withAnimation(.easeOut(duration: 1.0)) {
            animationScale = 1.2
            animationOpacity = 1.0
        }
        
        // Fireworks effect with additional sound
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            AudioServicesPlaySystemSound(1013) // Pop sound
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animationScale = 1.0
            }
        }
        
        // Additional sparkle sound
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            AudioServicesPlaySystemSound(1057) // Tweet sound
        }
        
        // Hide animation after 4 seconds (added extra second)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            withAnimation(.easeInOut(duration: 0.5)) {
                showLaunchAnimation = false
            }
        }
    }
    
    private func handleImageSelected(_ image: UIImage) {
        selectedImage = image
        Task {
            await analyzeProblem()
        }
    }
    
    
    private func analyzeProblem() async {
        print("🚨 CRITICAL DEBUG: analyzeProblem() function called!")
        isProcessing = true
        
        do {
            guard let userId = dataManager.currentUser?.id else { 
                isProcessing = false
                return 
            }
            
            var imageData: Data?
            if let image = selectedImage {
                imageData = image.jpegData(compressionQuality: 0.8)
            }
            
            if imageData == nil {
                alertMessage = "Please upload an image"
                showAlert = true
                isProcessing = false
                return
            }
            
            // Update processing message based on what we're doing
            if imageData != nil {
                processingMessage = "Reading specific problems from your homework..."
                await MainActor.run { }
            } else {
                processingMessage = "Analyzing your problem..."
                await MainActor.run { }
            }
            
            let userGradeLevel = dataManager.currentUser?.getGradeLevel() ?? "elementary"
            print("🔍 DEBUG HomeView: Starting homework analysis")
            print("   Device: \(UIDevice.current.model)")
            print("   iOS Version: \(UIDevice.current.systemVersion)")
            print("   User ID: \(userId)")
            print("   User grade level: \(userGradeLevel)")
            print("   Image data size: \(imageData?.count ?? 0) bytes")
            print("   Network reachability: \(await checkNetworkReachability())")
            
            // Add timeout wrapper for device compatibility
            let analysis = try await withTimeout(seconds: 300) {
                try await BackendAPIService.shared.analyzeHomework(
                    imageData: imageData,
                    problemText: nil,
                    userGradeLevel: userGradeLevel
                )
            }
            
            print("🔍 DEBUG HomeView: Analysis completed successfully")
            print("   Subject: \(analysis.subject)")
            print("   Difficulty: \(analysis.difficulty)")
            print("   Number of steps: \(analysis.steps.count)")
            
            processingMessage = "Creating step-by-step solutions..."
            await MainActor.run { }
            
            var problem = HomeworkProblem(
                userId: userId,
                problemText: nil,
                imageFilename: nil,
                subject: analysis.subject,
                status: .inProgress,
                totalSteps: analysis.steps.count
            )
            
            print("🔍 DEBUG HomeView: Created problem with ID: \(problem.id)")
            
            if let imgData = imageData {
                let imageFilename = dataManager.saveImage(imgData, forProblemId: problem.id)
                problem.imageFilename = imageFilename
            }
            
            dataManager.addProblem(problem)
            print("🔍 DEBUG HomeView: Added problem to DataManager")
            
            // Add all steps first
            print("🔍 DEBUG HomeView: Adding \(analysis.steps.count) steps to DataManager")
            for (index, stepData) in analysis.steps.enumerated() {
                let step = GuidanceStep(
                    problemId: problem.id,
                    stepNumber: index + 1,
                    question: stepData.question,
                    explanation: stepData.explanation,
                    options: stepData.options,
                    correctAnswer: stepData.correctAnswer
                )
                print("🔍 DEBUG HomeView: Adding step \(index + 1) of \(analysis.steps.count)")
                dataManager.addStep(step, for: problem.id)
            }
            
            print("🔍 DEBUG HomeView: Finished adding steps, waiting for DataManager to sync...")
            
            // Wait for DataManager to finish adding steps
            var attempts = 0
            let maxAttempts = 50 // 5 seconds max wait
            
            while dataManager.steps[problem.id.uuidString]?.count != analysis.steps.count && attempts < maxAttempts {
                try await Task.sleep(nanoseconds: 100_000_000) // 100ms intervals
                attempts += 1
                print("🔍 DEBUG HomeView: Waiting for steps... Attempt \(attempts)/\(maxAttempts). Current count: \(dataManager.steps[problem.id.uuidString]?.count ?? 0), Expected: \(analysis.steps.count)")
            }
            
            let finalStepCount = dataManager.steps[problem.id.uuidString]?.count ?? 0
            print("🔍 DEBUG HomeView: Final step count: \(finalStepCount), Expected: \(analysis.steps.count)")
            
            if finalStepCount != analysis.steps.count {
                print("⚠️ WARNING: Step count mismatch! Expected \(analysis.steps.count), got \(finalStepCount)")
            } else {
                print("✅ DEBUG HomeView: All steps successfully added to DataManager")
            }
            
            await MainActor.run {
                print("🚨 CRITICAL DEBUG: Analysis completed successfully! Navigating to StepGuidanceView")
                print("🚨 CRITICAL DEBUG: Problem ID: \(problem.id)")
                print("🚨 CRITICAL DEBUG: Steps added: \(dataManager.steps[problem.id.uuidString]?.count ?? 0)")
                currentProblemId = problem.id
                selectedImage = nil
                navigateToGuidance = true
            }
            
        } catch {
            print("🚨 CRITICAL DEBUG: Analysis failed with error: \(error)")
            print("🚨 CRITICAL DEBUG: Error type: \(type(of: error))")
            await MainActor.run {
                alertMessage = "Error: \(error.localizedDescription)"
                showAlert = true
                isProcessing = false
            }
        }
    }
    
    // MARK: - Image Analysis with Quality Check
    
    private func analyzeImageWithQualityCheck(_ image: UIImage) {
        logger.critical("🚨 CRITICAL DEBUG: analyzeImageWithQualityCheck() function called!")
        
        // Immediately set processing state on main thread
        isProcessing = true
        processingMessage = "Preparing image..."
        
        // Do ALL image processing in background task to avoid freezing
        Task.detached(priority: .userInitiated) {
            // Convert to JPEG in background (can be slow!)
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                await MainActor.run {
                    logger.critical("❌ CRITICAL DEBUG: Failed to convert image to JPEG data")
                    alertMessage = "Failed to process image"
                    showAlert = true
                    isProcessing = false
                }
                return
            }
            
            await MainActor.run {
                logger.critical("🚨 CRITICAL DEBUG: Image converted to JPEG data, size: \(imageData.count) bytes")
                selectedImage = image
                processingMessage = "Checking image quality..."
            }
            
            // Continue with quality check
            do {
                logger.critical("🚨 CRITICAL DEBUG: Starting image quality validation...")
                // First, validate image quality
                let qualityResult = try await backendService.validateImageQuality(imageData: imageData)
                logger.critical("🚨 CRITICAL DEBUG: Image quality validation completed. Is good quality: \(qualityResult.isGoodQuality)")
                
                await MainActor.run {
                    if !qualityResult.isGoodQuality {
                        // Show quality issues
                        var message = "Image quality issues detected:\n\n"
                        
                        if !qualityResult.issues.isEmpty {
                            message += "Issues:\n"
                            for issue in qualityResult.issues {
                                message += "• \(issue)\n"
                            }
                        }
                        
                        if !qualityResult.recommendations.isEmpty {
                            message += "\nRecommendations:\n"
                            for recommendation in qualityResult.recommendations {
                                message += "• \(recommendation)\n"
                            }
                        }
                        
                        message += "\nPlease try uploading a clearer image."
                        imageQualityMessage = message
                        showImageQualityAlert = true
                        isProcessing = false
                        return
                    }
                    
                    // Quality is good, proceed with analysis
                    processingMessage = "Image quality looks good! Starting analysis..."
                }
                
                // Analyze the homework
                logger.critical("🚨 CRITICAL DEBUG: Starting homework analysis...")
                let userGradeLevel = dataManager.currentUser?.getGradeLevel() ?? "elementary"
                logger.critical("🚨 CRITICAL DEBUG: User grade level: \(userGradeLevel)")
                let analysis = try await backendService.analyzeHomework(
                    imageData: imageData,
                    problemText: nil,
                    userGradeLevel: userGradeLevel
                )
                
                logger.critical("🚨 CRITICAL DEBUG: Homework analysis completed successfully!")
                logger.critical("🚨 CRITICAL DEBUG: Analysis result - Subject: \(analysis.subject), Difficulty: \(analysis.difficulty), Steps: \(analysis.steps.count)")
                
                await MainActor.run {
                    // Create problem from analysis
                    let problem = HomeworkProblem(
                        id: UUID(),
                        userId: dataManager.currentUser?.id ?? UUID(),
                        subject: analysis.subject,
                        totalSteps: analysis.steps.count,
                        completedSteps: 0
                    )
                    
                    dataManager.addProblem(problem)
                    
                    // Add all steps from analysis
                    for (index, stepData) in analysis.steps.enumerated() {
                        let step = GuidanceStep(
                            problemId: problem.id,
                            stepNumber: index + 1,
                            question: stepData.question,
                            explanation: stepData.explanation,
                            options: stepData.options,
                            correctAnswer: stepData.correctAnswer
                        )
                        dataManager.addStep(step, for: problem.id)
                    }
                    
                    currentProblemId = problem.id
                    navigateToGuidance = true
                    isProcessing = false
                }
                
            } catch {
                logger.critical("🚨 CRITICAL DEBUG: analyzeImageWithQualityCheck failed with error: \(error)")
                logger.critical("🚨 CRITICAL DEBUG: Error type: \(type(of: error))")
                await MainActor.run {
                    alertMessage = "Error: \(error.localizedDescription)"
                    showAlert = true
                    isProcessing = false
                }
            }
        }
    }
    
    private func analyzeImageIgnoringQuality() async {
        guard let image = selectedImage,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            await MainActor.run {
                alertMessage = "Failed to process image"
                showAlert = true
            }
            return
        }
        
        await MainActor.run {
            isProcessing = true
            processingMessage = "Starting analysis..."
        }
        
        do {
            // Analyze the homework directly without quality check
            let userGradeLevel = dataManager.currentUser?.getGradeLevel() ?? "elementary"
            let analysis = try await backendService.analyzeHomework(
                imageData: imageData,
                problemText: nil,
                userGradeLevel: userGradeLevel
            )
            
            await MainActor.run {
                // Create problem from analysis
                var problem = HomeworkProblem(
                    id: UUID(),
                    userId: dataManager.currentUser?.id ?? UUID(),
                    subject: analysis.subject,
                    totalSteps: analysis.steps.count,
                    completedSteps: 0
                )
                
                let imageFilename = dataManager.saveImage(imageData, forProblemId: problem.id)
                problem.imageFilename = imageFilename
                
                dataManager.addProblem(problem)
                
                // Add all steps from analysis
                for (index, stepData) in analysis.steps.enumerated() {
                    let step = GuidanceStep(
                        problemId: problem.id,
                        stepNumber: index + 1,
                        question: stepData.question,
                        explanation: stepData.explanation,
                        options: stepData.options,
                        correctAnswer: stepData.correctAnswer
                    )
                    dataManager.addStep(step, for: problem.id)
                }
                
                currentProblemId = problem.id
                selectedImage = nil
                navigateToGuidance = true
                isProcessing = false
            }
            
        } catch {
            await MainActor.run {
                alertMessage = "Error: \(error.localizedDescription)"
                showAlert = true
                isProcessing = false
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType
    let onImageSelected: ((UIImage) -> Void)?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        logger.critical("🚨 CRITICAL DEBUG: ImagePicker makeUIViewController called with sourceType: \(sourceType.rawValue)")
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        logger.critical("🚨 CRITICAL DEBUG: ImagePicker created successfully")
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            logger.critical("🚨 CRITICAL DEBUG: ImagePicker didFinishPickingMediaWithInfo called!")
            if let image = info[.originalImage] as? UIImage {
                logger.critical("🚨 CRITICAL DEBUG: Image selected successfully, size: \(image.size.width)x\(image.size.height)")
                parent.image = image
                logger.critical("🚨 CRITICAL DEBUG: Calling onImageSelected callback...")
                parent.onImageSelected?(image)
                logger.critical("🚨 CRITICAL DEBUG: onImageSelected callback completed")
            } else {
                logger.critical("❌ CRITICAL DEBUG: Failed to get image from picker")
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Triangle Shape for Speech Bubble
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
