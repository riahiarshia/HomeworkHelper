import SwiftUI

struct ProblemsListView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedFilter: ProblemFilter = .all
    let isSubscriptionExpired: Bool
    
    enum ProblemFilter: String, CaseIterable {
        case all = "All"
        case inProgress = "In Progress"
        case completed = "Completed"
    }
    
    private var filteredProblems: [HomeworkProblem] {
        let sorted = dataManager.problems.sorted(by: { $0.createdAt > $1.createdAt })
        switch selectedFilter {
        case .all:
            return sorted
        case .inProgress:
            return sorted.filter { $0.status == .inProgress }
        case .completed:
            return sorted.filter { $0.status == .completed }
        }
    }
    
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
                
                VStack {
                    filterPicker
                    
                    if filteredProblems.isEmpty {
                        emptyStateView
                    } else {
                        List(filteredProblems) { problem in
                            NavigationLink(destination: ProblemDetailView(problem: problem)) {
                                ProblemRow(problem: problem)
                            }
                            .listRowBackground(Color.white)
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("My Problems")
        }
    }
    
    private var filterPicker: some View {
        Picker("Filter", selection: $selectedFilter) {
            ForEach(ProblemFilter.allCases, id: \.self) { filter in
                Text(filter.rawValue).tag(filter)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Problems")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Upload homework to get started!")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxHeight: .infinity)
    }
}

struct ProblemRow: View {
    let problem: HomeworkProblem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let subject = problem.subject {
                    Text(subject)
                        .font(.caption)
                        .padding(4)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)
                }
                
                Spacer()
                
                statusBadge
            }
            
            if let text = problem.problemText, !text.isEmpty {
                Text(text)
                    .font(.body)
                    .lineLimit(2)
            } else {
                Text("Image Problem")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text(formatDate(problem.createdAt))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if problem.status == .completed, let points = problem.pointsAwarded {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                        Text("\(points) pts")
                            .font(.caption)
                    }
                    .foregroundColor(.orange)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var statusBadge: some View {
        Text(problem.status.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
            .font(.caption)
            .padding(4)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(4)
    }
    
    private var statusColor: Color {
        switch problem.status {
        case .pending: return .gray
        case .inProgress: return .blue
        case .completed: return .green
        case .needsReview: return .orange
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ProblemDetailView: View {
    let problem: HomeworkProblem
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showDeleteAlert = false
    @State private var selectedStepIndex: Int?
    @State private var showPrerequisiteAlert = false
    @State private var prerequisiteMessage = ""
    
    private var steps: [GuidanceStep] {
        dataManager.steps[problem.id.uuidString]?.sorted(by: { $0.stepNumber < $1.stepNumber }) ?? []
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let filename = problem.imageFilename,
                   let imageData = dataManager.loadImage(filename: filename),
                   let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .shadow(radius: 4)
                }
                
                if let text = problem.problemText {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Problem")
                            .font(.headline)
                        Text(text)
                            .font(.body)
                    }
                }
                
                statsSection
                
                if !steps.isEmpty {
                    stepsSection
                }
                
                actionButtons
            }
            .padding()
        }
        .navigationTitle(problem.subject ?? "Problem")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .alert("Delete Problem?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteProblem()
            }
        } message: {
            Text("Are you sure you want to delete this problem? This action cannot be undone.")
        }
        .alert("Prerequisites Required", isPresented: $showPrerequisiteAlert) {
            Button("OK") { }
        } message: {
            Text(prerequisiteMessage)
        }
        .navigationDestination(isPresented: Binding(
            get: { selectedStepIndex != nil },
            set: { if !$0 { selectedStepIndex = nil } }
        )) {
            if let stepIndex = selectedStepIndex {
                StepGuidanceView(problemId: problem.id, startFromStep: stepIndex)
            }
        }
    }
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics")
                .font(.headline)
            
            HStack(spacing: 24) {
                StatView(label: "Total Steps", value: "\(problem.totalSteps)")
                StatView(label: "Completed", value: "\(problem.completedSteps)")
                if problem.skippedSteps > 0 {
                    StatView(label: "Skipped", value: "\(problem.skippedSteps)")
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Steps")
                    .font(.headline)
                Spacer()
                Text("Tap any step to work on it")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                Button {
                    if canAccessStep(step, at: index) {
                        selectedStepIndex = index
                    } else {
                        showPrerequisiteAlert = true
                        prerequisiteMessage = getPrerequisiteMessage(for: step, at: index)
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            // Step status icon
                            Image(systemName: getStepIcon(for: step, at: index))
                                .foregroundColor(getStepIconColor(for: step, at: index))
                            
                            Text("Step \(step.stepNumber)")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(canAccessStep(step, at: index) ? .primary : .secondary)
                            
                            // Status text
                            if step.isSkipped {
                                Text("(Skipped)")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            } else if step.isCompleted {
                                Text("(Completed)")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            } else if !canAccessStep(step, at: index) {
                                Text("(Locked)")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            } else if selectedStepIndex == index {
                                Text("(Selected)")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            
                            Spacer()
                            
                            // Chevron or lock icon
                            Image(systemName: canAccessStep(step, at: index) ? "chevron.right" : "lock.fill")
                                .font(.caption)
                                .foregroundColor(canAccessStep(step, at: index) ? .gray : .red)
                        }
                        
                        // Show step question as description
                        Text(step.question)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                        
                        // Show explanation if completed
                        if step.isCompleted {
                            Text(step.explanation)
                                .font(.caption)
                                .foregroundColor(.blue)
                                .lineLimit(1)
                        }
                    }
                    .padding()
                    .background(
                        selectedStepIndex == index 
                            ? LinearGradient(
                                gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.15)]),
                                startPoint: .leading,
                                endPoint: .trailing
                              )
                            : LinearGradient(
                                gradient: Gradient(colors: [Color.gray.opacity(0.05), Color.gray.opacity(0.05)]),
                                startPoint: .leading,
                                endPoint: .trailing
                              )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(selectedStepIndex == index ? Color.blue : Color.clear, lineWidth: 2)
                    )
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            if problem.status == .inProgress || problem.status == .pending {
                NavigationLink(destination: StepGuidanceView(problemId: problem.id)) {
                    HStack {
                        Image(systemName: problem.status == .pending ? "play.fill" : "arrow.right.circle.fill")
                        Text(problem.status == .pending ? "Start Problem" : "Continue")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            } else if problem.status == .completed {
                VStack(spacing: 12) {
                    // Allow working on any step of completed problems
                    NavigationLink(destination: StepGuidanceView(problemId: problem.id)) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                            Text("Work on Problem")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    Button {
                        restartProblem()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Restart from Beginning")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
            }
        }
    }
    
    private func deleteProblem() {
        // Delete problem and associated data
        dataManager.problems.removeAll { $0.id == problem.id }
        dataManager.steps.removeValue(forKey: problem.id.uuidString)
        dataManager.messages.removeValue(forKey: problem.id.uuidString)
        
        // Delete image file if exists
        if let filename = problem.imageFilename {
            dataManager.deleteImage(filename: filename)
        }
        
        dataManager.saveData()
        presentationMode.wrappedValue.dismiss()
    }
    
    private func restartProblem() {
        // Reset all steps to not completed
        if var stepsForProblem = dataManager.steps[problem.id.uuidString] {
            for i in 0..<stepsForProblem.count {
                stepsForProblem[i].isCompleted = false
                stepsForProblem[i].isSkipped = false
                stepsForProblem[i].userAnswer = nil
            }
            dataManager.steps[problem.id.uuidString] = stepsForProblem
        }
        
        // Reset problem status
        if let index = dataManager.problems.firstIndex(where: { $0.id == problem.id }) {
            dataManager.problems[index].status = .pending
            dataManager.problems[index].completedSteps = 0
            dataManager.problems[index].skippedSteps = 0
        }
        
        dataManager.saveData()
    }
    
    private func canAccessStep(_ step: GuidanceStep, at index: Int) -> Bool {
        // If step doesn't require previous steps, always allow access
        if !step.requiresPreviousSteps {
            return true
        }
        
        // Check if all previous steps are completed or skipped
        let previousSteps = steps.prefix(index)
        return previousSteps.allSatisfy { $0.isCompleted || $0.isSkipped }
    }
    
    private func getPrerequisiteMessage(for step: GuidanceStep, at index: Int) -> String {
        let incompleteSteps = steps.prefix(index).filter { !$0.isCompleted && !$0.isSkipped }
        
        if incompleteSteps.isEmpty {
            return "This step requires previous steps to be completed first. Please complete the previous steps before accessing this one."
        } else {
            let stepNumbers = incompleteSteps.map { "Step \($0.stepNumber)" }.joined(separator: ", ")
            return "This step requires the following steps to be completed first: \(stepNumbers). Please complete those steps before accessing Step \(step.stepNumber)."
        }
    }
    
    private func getStepIcon(for step: GuidanceStep, at index: Int) -> String {
        if !canAccessStep(step, at: index) {
            return "lock.circle.fill"
        } else if step.isCompleted {
            return "checkmark.circle.fill"
        } else if step.isSkipped {
            return "forward.circle.fill"
        } else {
            return "circle"
        }
    }
    
    private func getStepIconColor(for step: GuidanceStep, at index: Int) -> Color {
        if !canAccessStep(step, at: index) {
            return .red
        } else if step.isCompleted {
            return .green
        } else if step.isSkipped {
            return .orange
        } else {
            return .gray
        }
    }
}

struct StatView: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
        }
    }
}

// MARK: - Preview
#Preview {
    ProblemsListView(isSubscriptionExpired: false)
        .environmentObject(DataManager.shared)
}
