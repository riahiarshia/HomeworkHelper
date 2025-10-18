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
    @EnvironmentObject var subscriptionService: SubscriptionService
    @StateObject private var backendService = BackendAPIService.shared
    @State private var showPaywall = false
    let isSubscriptionExpired: Bool
    let skipLaunchAnimation: Bool
    
    init(isSubscriptionExpired: Bool = false, skipLaunchAnimation: Bool = false) {
        self.isSubscriptionExpired = isSubscriptionExpired
        self.skipLaunchAnimation = skipLaunchAnimation
        logger.critical("🚨 CRITICAL DEBUG: HomeView init called! isSubscriptionExpired: \(isSubscriptionExpired)")
    }
    
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var showImageCropper = false
    @State private var tempImageForCropping: UIImage?
    @State private var pendingImageSource: ImageSource? = nil
    
    // Teacher method states
    @State private var showTeacherMethodPrompt = false
    @State private var teacherMethodImage: UIImage?
    @State private var showTeacherMethodCamera = false
    @State private var showTeacherMethodImagePicker = false
    @State private var showTeacherMethodCropper = false
    @State private var tempTeacherMethodImage: UIImage?
    @State private var isCapturingTeacherMethod = false
    
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
    @State private var bigBrainAnimation = false
    @State private var handTapAnimation = false
    @State private var showBigBrainText = false
    @State private var currentBrainPhrase = "BIG BRAIN!"
    @State private var logoRotation: Double = 0
    @State private var logoOffset: CGFloat = -200
    @State private var logoFinalPosition: CGSize = .zero
    @State private var processingLogoRotation: Double = 0
    @State private var logoDragOffset: CGSize = .zero
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient (more purple, less pink)
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.4, green: 0.2, blue: 0.8).opacity(0.9), Color(red: 0.2, green: 0.4, blue: 0.9).opacity(0.7)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        if isProcessing {
                            processingView
                        }
                        
                        // Upload section at the top
                        uploadSection
                        
                        // Hidden NavigationLink for navigation to StepGuidanceView
                        NavigationLink(
                            destination: destinationView,
                            isActive: $navigateToGuidance
                        ) {
                            EmptyView()
                        }
                        .hidden()
                        
                        if selectedImage != nil && !navigateToGuidance {
                            imagePreview
                        }
                        
                        // Remaining content
                        contentSection
                        
                        // Subscription info at the bottom
                        subscriptionBanner
                    }
                    .padding()
                }
                .navigationTitle("Ai Homework Helper")
                .navigationBarTitleDisplayMode(.large)
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("home_view")
                .sheet(isPresented: $showPaywall) {
                    PaywallView()
                }
                
                // Draggable logo overlay
                draggableLogo
            }
            .onAppear {
                logger.critical("🚨 CRITICAL DEBUG: HomeView onAppear called!")
                
                // Clear any previous image when returning to home
                if navigateToGuidance {
                    selectedImage = nil
                    navigateToGuidance = false
                }
                
                // Refresh subscription status when home view appears
                Task {
                    print("🏠 HomeView - Refreshing subscription status")
                    await subscriptionService.refreshSubscriptionStatus()
                    print("🏠 HomeView - Subscription status: \(subscriptionService.subscriptionStatus)")
                }
            }
            .navigationDestination(isPresented: $navigateToGuidance) {
                destinationView
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $tempImageForCropping, sourceType: .photoLibrary, onImageSelected: { image in
                    logger.critical("🚨 CRITICAL DEBUG: Photo library onImageSelected callback - setting tempImageForCropping")
                    tempImageForCropping = image
                    selectedImage = nil
                    showImagePicker = false
                    
                    // Wait for sheet to dismiss, then show cropper
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        logger.critical("🚨 CRITICAL DEBUG: About to show ImageCropper with image")
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
            .sheet(isPresented: $showTeacherMethodPrompt) {
                teacherMethodPromptSheet
            }
            .sheet(isPresented: $showTeacherMethodCamera) {
                ImagePicker(image: $tempTeacherMethodImage, sourceType: .camera, onImageSelected: { image in
                    print("📸 Teacher method image captured from camera")
                    tempTeacherMethodImage = image
                    showTeacherMethodCamera = false
                    
                    // Wait for sheet to dismiss, then show cropper
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showTeacherMethodCropper = true
                    }
                })
            }
            .sheet(isPresented: $showTeacherMethodImagePicker) {
                ImagePicker(image: $tempTeacherMethodImage, sourceType: .photoLibrary, onImageSelected: { image in
                    print("📸 Teacher method image selected from photo library")
                    tempTeacherMethodImage = image
                    showTeacherMethodImagePicker = false
                    
                    // Wait for sheet to dismiss, then show cropper
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showTeacherMethodCropper = true
                    }
                })
            }
            .sheet(isPresented: $showTeacherMethodCropper) {
                ImageCropperView(image: $tempTeacherMethodImage, onCrop: { croppedImage in
                    print("✂️ Teacher method image cropped")
                    // Dismiss sheet first
                    showTeacherMethodCropper = false
                    
                    // Save the teacher method image
                    teacherMethodImage = croppedImage
                    tempTeacherMethodImage = nil
                    
                    // Wait for sheet to fully dismiss before starting analysis
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        proceedWithAnalysis()
                    }
                })
                .interactiveDismissDisabled(false)
            }
        }
    }
    
    @ViewBuilder
    private var destinationView: some View {
        if let problemId = currentProblemId {
            StepGuidanceView(problemId: problemId)
        }
    }
    
    private var teacherMethodPromptSheet: some View {
        NavigationView {
            ZStack {
                // Background gradient matching app theme
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.4, green: 0.2, blue: 0.8).opacity(0.9), Color(red: 0.2, green: 0.4, blue: 0.9).opacity(0.7)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Owl logo
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                    
                    if !isCapturingTeacherMethod {
                        // Initial prompt
                        VStack(spacing: 16) {
                            Text("Teacher's Method?")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Did your teacher show you a specific way to solve this problem?")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        
                        // Buttons
                        VStack(spacing: 16) {
                            Button {
                                showTeacherMethodChoice()
                            } label: {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Yes, I have it")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(12)
                            }
                            
                            Button {
                                showTeacherMethodPrompt = false
                                proceedWithAnalysis()
                            } label: {
                                HStack {
                                    Image(systemName: "xmark.circle.fill")
                                    Text("No, I don't")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 40)
                    } else {
                        // Teacher method upload options
                        VStack(spacing: 16) {
                            Text("Upload Teacher's Method")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Take a photo of your teacher's solution or choose from your library")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        
                        VStack(spacing: 16) {
                            Button {
                                showTeacherMethodPrompt = false
                                showTeacherMethodCamera = true
                            } label: {
                                HStack {
                                    Image(systemName: "camera.fill")
                                    Text("Take Photo")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                            }
                            
                            Button {
                                showTeacherMethodPrompt = false
                                showTeacherMethodImagePicker = true
                            } label: {
                                HStack {
                                    Image(systemName: "photo.fill")
                                    Text("Photo Library")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple)
                                .cornerRadius(12)
                            }
                            
                            Button {
                                showTeacherMethodPrompt = false
                                isCapturingTeacherMethod = false
                                proceedWithAnalysis()
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.right.circle.fill")
                                    Text("Skip & Continue")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 40)
                    }
                }
            }
            .navigationBarItems(trailing: Button("Cancel") {
                showTeacherMethodPrompt = false
                isCapturingTeacherMethod = false
                selectedImage = nil
                isProcessing = false
            })
        }
    }
    
    private var draggableLogo: some View {
            ZStack {
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                .frame(width: 180, height: 180)
                    .scaleEffect(bigBrainAnimation ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: bigBrainAnimation)
                .offset(y: logoOffset)
                .offset(logoFinalPosition)
                .offset(logoDragOffset)
                .rotationEffect(.degrees(logoRotation))
                .onAppear {
                    // Play whistle sound when logo starts entering
                    AudioServicesPlaySystemSound(1016) // Whistle/fanfare sound
                    
                    // Start entrance animation from top
                    withAnimation(.easeOut(duration: 1.0)) {
                        logoOffset = 0
                    }
                    
                    // Move to center of buttons after dropping down
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            // Position logo between camera and photo library buttons
                            logoFinalPosition = CGSize(width: 0, height: -180) // Move up higher to avoid covering text
                        }
                    }
                    
                    // Spin twice and play audio after moving to position
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                        withAnimation(.linear(duration: 2.0)) {
                            logoRotation = 720 // Two full spins (360 * 2)
                        }
                        
                        // Play audio message after spinning
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            playWelcomeMessage()
                        }
                    }
                }
                .onTapGesture {
                    startBigBrainAnimation()
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            logoDragOffset = value.translation
                        }
                        .onEnded { value in
                            logoDragOffset = value.translation
                        }
                )
                
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
                .offset(x: logoDragOffset.width, y: logoDragOffset.height + logoOffset + logoFinalPosition.height - 130) // Follow logo movement
            }
        }
    }
    
    
    private var contentSection: some View {
        VStack(spacing: 16) {
            Text("Learn by Solving")
                .font(.title2)
                .foregroundColor(.white)
                .accessibilityIdentifier("learn_by_solving")
            
            // Tagline
            VStack(spacing: 4) {
                Text("Your AI Tutor for Step-by-Step Learning")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("No Cheating - Real Learning")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
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
        VStack(spacing: 20) {
            // Upload Your Homework heading
            Text("Upload Your Homework")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Camera and Photo Library buttons side by side
            HStack(spacing: 0) {
                // Camera button (left side)
                Button {
                    // Allow expired users to take photos - paywall will show later when they try to get AI guidance
                    logger.critical("🚨 CRITICAL DEBUG: Camera button tapped!")
                    pendingImageSource = .camera
                    showCamera = true
                } label: {
                    VStack {
                        Image(systemName: "camera.fill")
                            .font(.title)
                            .foregroundColor(.black)
                        Text("Camera")
                            .font(.headline)
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(12)
                }
                .accessibilityIdentifier("camera_button")
                .disabled(isProcessing)
                
                // Vertical separator
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 1)
                    .frame(height: 100)
                
                // Photo Library button (right side)
                Button {
                    // Allow expired users to select photos - paywall will show later when they try to get AI guidance
                    logger.critical("🚨 CRITICAL DEBUG: Photo Library button tapped!")
                    pendingImageSource = .photoLibrary
                    showImagePicker = true
                } label: {
                    VStack {
                        Image(systemName: "photo.fill")
                            .font(.title)
                            .foregroundColor(.black)
                        Text("Photo Library")
                            .font(.headline)
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(12)
                }
                .accessibilityIdentifier("photo_library_button")
                .disabled(isProcessing)
            }
            
            if isSubscriptionExpired {
                Text("Limited access - Subscribe for full AI guidance")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
        }
        .padding(.vertical, 24) // Increased padding for upload section at top
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
            // Animated logo with spinning effect
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(processingLogoRotation))
                .onAppear {
                    // Start spinning animation during processing
                    withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                        processingLogoRotation = 360
                    }
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
    
    private func playWelcomeMessage() {
        // Welcome messages for logo entrance
        let welcomeMessages = [
            "Hi there! Ready to learn?",
            "Hello! Let's solve some problems together!",
            "Hey! I'm here to help you succeed!",
            "Welcome! Time for some smart thinking!",
            "Hello! Ready to be a big brain today?"
        ]
        
        let randomMessage = welcomeMessages.randomElement() ?? "Hi there! Ready to learn?"
        
        // Create speech utterance
        let utterance = AVSpeechUtterance(string: randomMessage)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5 // Slightly slower for friendliness
        utterance.pitchMultiplier = 1.1 // Slightly higher for enthusiasm
        utterance.volume = 0.8
        
        // Speak it!
        speechSynthesizer.speak(utterance)
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
        processingLogoRotation = 0 // Reset rotation for processing animation
        
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
    
    // MARK: - Teacher Method Workflow
    
    private func showTeacherMethodChoice() {
        // Show action sheet to choose camera or photo library for teacher method
        isCapturingTeacherMethod = true
        // The user will see the teacher method upload options below the prompt
    }
    
    private func proceedWithAnalysis() {
        guard let image = selectedImage else {
            alertMessage = "No problem image found"
            showAlert = true
            return
        }
        
        // Start the actual analysis with both images
        performImageAnalysis(problemImage: image, teacherMethodImage: teacherMethodImage)
    }
    
    // MARK: - Image Analysis with Quality Check
    
    private func analyzeImageWithQualityCheck(_ image: UIImage) {
        logger.critical("🚨 CRITICAL DEBUG: analyzeImageWithQualityCheck() function called!")
        
        // Save the selected image
        selectedImage = image
        
        // Show teacher method prompt
        showTeacherMethodPrompt = true
    }
    
    private func performImageAnalysis(problemImage: UIImage, teacherMethodImage: UIImage?) {
        logger.critical("🚨 CRITICAL DEBUG: performImageAnalysis() function called!")
        
        // Immediately set processing state on main thread
        isProcessing = true
        processingLogoRotation = 0 // Reset rotation for processing animation
        processingMessage = "Preparing image..."
        
        // Do ALL image processing in background task to avoid freezing
        Task.detached(priority: .userInitiated) {
            // Convert problem image to JPEG in background (can be slow!)
            guard let imageData = problemImage.jpegData(compressionQuality: 0.8) else {
                await MainActor.run {
                    logger.critical("❌ CRITICAL DEBUG: Failed to convert problem image to JPEG data")
                    alertMessage = "Failed to process problem image"
                    showAlert = true
                    isProcessing = false
                }
                return
            }
            
            // Convert teacher method image to JPEG if provided
            var teacherMethodImageData: Data? = nil
            if let methodImage = teacherMethodImage {
                teacherMethodImageData = methodImage.jpegData(compressionQuality: 0.8)
                logger.critical("🚨 CRITICAL DEBUG: Teacher method image converted, size: \(teacherMethodImageData?.count ?? 0) bytes")
            }
            
            await MainActor.run {
                logger.critical("🚨 CRITICAL DEBUG: Problem image converted to JPEG data, size: \(imageData.count) bytes")
                processingMessage = "Checking image quality..."
            }
            
            // Continue with quality check
            do {
                logger.critical("🚨 CRITICAL DEBUG: Starting image quality validation...")
                // First, validate image quality
                let userId = await MainActor.run { dataManager.currentUser?.userId }
                let qualityResult = try await backendService.validateImageQuality(imageData: imageData, userId: userId)
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
                let userGradeLevel = await MainActor.run { dataManager.currentUser?.getGradeLevel() ?? "elementary" }
                logger.critical("🚨 CRITICAL DEBUG: User grade level: \(userGradeLevel)")
                logger.critical("🚨 CRITICAL DEBUG: User ID: \(userId ?? "nil")")
                logger.critical("🚨 CRITICAL DEBUG: Has teacher method image: \(teacherMethodImageData != nil)")
                let analysis = try await backendService.analyzeHomework(
                    imageData: imageData,
                    problemText: nil,
                    userGradeLevel: userGradeLevel,
                    userId: userId,
                    teacherMethodImageData: teacherMethodImageData
                )
                
                logger.critical("🚨 CRITICAL DEBUG: Homework analysis completed successfully!")
                logger.critical("🚨 CRITICAL DEBUG: Analysis result - Subject: \(analysis.subject), Difficulty: \(analysis.difficulty), Steps: \(analysis.steps.count)")
                
                // Capture teacherMethodImageData before MainActor to avoid concurrency issues
                let capturedMethodData = teacherMethodImageData
                
                await MainActor.run {
                    // Create problem from analysis
                    var problem = HomeworkProblem(
                        id: UUID(),
                        userId: dataManager.currentUser?.id ?? UUID(),
                        subject: analysis.subject,
                        totalSteps: analysis.steps.count,
                        completedSteps: 0
                    )
                    
                    // Save problem image
                    let problemImageFilename = dataManager.saveImage(imageData, forProblemId: problem.id)
                    problem.imageFilename = problemImageFilename
                    
                    // Save teacher method image if provided
                    if let methodData = capturedMethodData {
                        let methodImageFilename = dataManager.saveImage(methodData, forProblemId: problem.id, suffix: "_method")
                        problem.teacherMethodImageFilename = methodImageFilename
                        logger.critical("🚨 CRITICAL DEBUG: Saved teacher method image: \(methodImageFilename ?? "unknown")")
                    }
                    
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
            let userId = dataManager.currentUser?.userId
            let analysis = try await backendService.analyzeHomework(
                imageData: imageData,
                problemText: nil,
                userGradeLevel: userGradeLevel,
                userId: userId
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
                
                // Track homework submission to backend
                Task {
                    do {
                        try await backendService.trackHomeworkSubmission(problem: problem)
                    } catch {
                        print("⚠️ Failed to track homework submission: \(error)")
                        // Don't fail the whole flow if tracking fails
                    }
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
    
    // MARK: - Subscription Banner
    @ViewBuilder
    private var subscriptionBanner: some View {
        HStack {
            // Subscriber info section
            VStack(alignment: .leading, spacing: 4) {
                Text("Subscriber")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                switch subscriptionService.subscriptionStatus {
                case .trial(let daysRemaining):
                    Text("Free Trial - \(daysRemaining) day\(daysRemaining == 1 ? "" : "s") left")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                case .active(let renewalDate):
                    Text("Premium - Renews \(renewalDate, style: .date)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                case .expired:
                    Text("Subscription Expired")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                case .unknown:
                    Text("Subscription status unknown")
                        .foregroundColor(.white.opacity(0.8))
                case .gracePeriod(daysRemaining: let daysRemaining):
                    Text("Grace period - \(daysRemaining) day\(daysRemaining == 1 ? "" : "s") left")
                        .foregroundColor(.white.opacity(0.8))
                    
                }
            }
            
            Spacer()
            
            // Renew button
            Button {
                showPaywall = true
            } label: {
                Text("Renew")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white.opacity(0.15))
        .cornerRadius(12)
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

// MARK: - Preview
#Preview {
    HomeView(skipLaunchAnimation: true)
        .environmentObject(DataManager.shared)
        .environmentObject(SubscriptionService.shared)
}
