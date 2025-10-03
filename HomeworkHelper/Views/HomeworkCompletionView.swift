import SwiftUI

struct HomeworkCompletionView: View {
    let problem: HomeworkProblem
    @Environment(\.dismiss) private var dismiss
    @State private var showConfetti = false
    @State private var animateStars = false
    @State private var showMessage = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1), Color.green.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Animated celebration icon
                ZStack {
                    // Rotating stars background
                    ForEach(0..<8) { index in
                        Image(systemName: "star.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.yellow)
                            .offset(
                                x: cos(Double(index) * .pi / 4) * 60,
                                y: sin(Double(index) * .pi / 4) * 60
                            )
                            .scaleEffect(animateStars ? 1.2 : 0.8)
                            .opacity(animateStars ? 1.0 : 0.3)
                            .animation(
                                .easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.1),
                                value: animateStars
                            )
                    }
                    
                    // Main celebration icon
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 120))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [.green, .blue]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(showMessage ? 1.0 : 0.5)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showMessage)
                }
                
                VStack(spacing: 16) {
                    Text("🎉 Congratulations! 🎉")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .opacity(showMessage ? 1.0 : 0.0)
                        .offset(y: showMessage ? 0 : 20)
                        .animation(.easeOut(duration: 0.8).delay(0.3), value: showMessage)
                    
                    Text("Homework Complete!")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .opacity(showMessage ? 1.0 : 0.0)
                        .offset(y: showMessage ? 0 : 20)
                        .animation(.easeOut(duration: 0.8).delay(0.5), value: showMessage)
                    
                    Text("You've successfully completed your \(problem.subject.lowercased()) homework!")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                        .opacity(showMessage ? 1.0 : 0.0)
                        .offset(y: showMessage ? 0 : 20)
                        .animation(.easeOut(duration: 0.8).delay(0.7), value: showMessage)
                }
                
                // Points and stats
                VStack(spacing: 12) {
                    HStack(spacing: 30) {
                        VStack {
                            Text("\(problem.pointsAwarded)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                            Text("Points Earned")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack {
                            Text("\(problem.completedSteps)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            Text("Steps Completed")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack {
                            Text("\(problem.skippedSteps)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            Text("Steps Skipped")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                    .opacity(showMessage ? 1.0 : 0.0)
                    .offset(y: showMessage ? 0 : 20)
                    .animation(.easeOut(duration: 0.8).delay(0.9), value: showMessage)
                }
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 16) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "house.fill")
                            Text("Back to Home")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    .opacity(showMessage ? 1.0 : 0.0)
                    .offset(y: showMessage ? 0 : 20)
                    .animation(.easeOut(duration: 0.8).delay(1.1), value: showMessage)
                    
                    Button(action: {
                        // Start new homework
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Start New Homework")
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                    }
                    .opacity(showMessage ? 1.0 : 0.0)
                    .offset(y: showMessage ? 0 : 20)
                    .animation(.easeOut(duration: 0.8).delay(1.3), value: showMessage)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            
            // Confetti animation
            if showConfetti {
                ConfettiView()
            }
        }
        .onAppear {
            startCelebration()
        }
    }
    
    private func startCelebration() {
        // Start the animation sequence
        withAnimation {
            showMessage = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                animateStars = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                showConfetti = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation {
                showConfetti = false
            }
        }
    }
}

struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []
    
    var body: some View {
        ZStack {
            ForEach(confettiPieces) { piece in
                Rectangle()
                    .fill(piece.color)
                    .frame(width: 8, height: 8)
                    .position(piece.position)
                    .rotationEffect(.degrees(piece.rotation))
            }
        }
        .onAppear {
            generateConfetti()
            animateConfetti()
        }
    }
    
    private func generateConfetti() {
        let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink]
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        for _ in 0..<50 {
            confettiPieces.append(ConfettiPiece(
                position: CGPoint(
                    x: CGFloat.random(in: 0...screenWidth),
                    y: -50
                ),
                color: colors.randomElement() ?? .blue,
                rotation: Double.random(in: 0...360),
                velocity: CGPoint(
                    x: Double.random(in: -2...2),
                    y: Double.random(in: 2...8)
                )
            ))
        }
    }
    
    private func animateConfetti() {
        let screenHeight = UIScreen.main.bounds.height
        
        for i in confettiPieces.indices {
            withAnimation(.linear(duration: Double.random(in: 2...4)).delay(Double(i) * 0.02)) {
                confettiPieces[i].position.y = screenHeight + 100
                confettiPieces[i].rotation += Double.random(in: 180...720)
            }
        }
    }
}

struct ConfettiPiece: Identifiable {
    let id = UUID()
    var position: CGPoint
    let color: Color
    var rotation: Double
    let velocity: CGPoint
}

#Preview {
    HomeworkCompletionView(problem: HomeworkProblem(
        id: UUID(),
        subject: "Math",
        difficulty: "Medium",
        steps: [],
        problemText: "Sample math problem",
        completedSteps: 5,
        skippedSteps: 0,
        status: .completed,
        pointsAwarded: 10
    ))
}
