import SwiftUI
import PhotosUI
import AudioToolbox
import AVFoundation

struct HomeView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var openAIService: OpenAIService
    
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var isProcessing = false
    @State private var processingMessage = ""
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
                ImagePicker(image: $selectedImage, sourceType: .photoLibrary, onImageSelected: handleImageSelected)
            }
            .sheet(isPresented: $showCamera) {
                ImagePicker(image: $selectedImage, sourceType: .camera, onImageSelected: handleImageSelected)
            }
            .alert("Error", isPresented: $showAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
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
                Text(processingMessage)
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
                processingMessage = "Verifying homework content..."
                await MainActor.run { }
                
                let verification = try await openAIService.verifyImage(imageData!)
                
                guard verification.isValidHomework else {
                    alertMessage = "This doesn't appear to be homework content. Please try a different image."
                    showAlert = true
                    isProcessing = false
                    selectedImage = nil
                    return
                }
                
                processingMessage = "Reading specific problems from your homework..."
                await MainActor.run { }
            } else {
                processingMessage = "Analyzing your problem..."
                await MainActor.run { }
            }
            
            let userGradeLevel = dataManager.currentUser?.getGradeLevel() ?? "elementary"
            let analysis = try await openAIService.analyzeProblem(
                imageData: imageData,
                problemText: nil,
                userGradeLevel: userGradeLevel
            )
            
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
            
            if let imgData = imageData {
                let imageFilename = dataManager.saveImage(imgData, forProblemId: problem.id)
                problem.imageFilename = imageFilename
            }
            
            dataManager.addProblem(problem)
            
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
            
        } catch {
            alertMessage = "Error: \(error.localizedDescription)"
            showAlert = true
        }
        
        isProcessing = false
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType
    let onImageSelected: ((UIImage) -> Void)?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
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
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
                parent.onImageSelected?(image)
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
