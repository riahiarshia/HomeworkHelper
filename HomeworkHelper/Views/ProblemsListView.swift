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
            VStack {
                filterPicker
                
                if filteredProblems.isEmpty {
                    emptyStateView
                } else {
                    List(filteredProblems) { problem in
                        NavigationLink(destination: ProblemDetailView(problem: problem)) {
                            ProblemRow(problem: problem)
                        }
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
                
                if problem.status == .inProgress {
                    NavigationLink(destination: StepGuidanceView(problemId: problem.id)) {
                        Text("Continue")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(problem.subject ?? "Problem")
        .navigationBarTitleDisplayMode(.inline)
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
            Text("Steps")
                .font(.headline)
            
            ForEach(steps) { step in
                HStack {
                    Image(systemName: step.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(step.isCompleted ? .green : .gray)
                    
                    Text("Step \(step.stepNumber)")
                        .font(.body)
                    
                    if step.isSkipped {
                        Text("(Skipped)")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
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
