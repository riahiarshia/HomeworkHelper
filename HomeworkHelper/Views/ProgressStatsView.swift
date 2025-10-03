import SwiftUI

struct ProgressStatsView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    userStatsCard
                    
                    if !dataManager.progress.isEmpty {
                        subjectProgressSection
                    } else {
                        emptyStateView
                    }
                }
                .padding()
            }
            .navigationTitle("Progress")
        }
    }
    
    private var userStatsCard: some View {
        VStack(spacing: 16) {
            if let user = dataManager.currentUser {
                HStack(spacing: 32) {
                    StatItem(
                        title: "Total Points",
                        value: "\(user.points)",
                        icon: "star.fill",
                        color: .orange
                    )
                    
                    StatItem(
                        title: "Current Streak",
                        value: "\(user.streak)",
                        icon: "flame.fill",
                        color: .red
                    )
                }
                
                Divider()
                
                HStack(spacing: 32) {
                    StatItem(
                        title: "Problems Solved",
                        value: "\(dataManager.problems.filter({ $0.status == .completed }).count)",
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                    
                    StatItem(
                        title: "In Progress",
                        value: "\(dataManager.problems.filter({ $0.status == .inProgress }).count)",
                        icon: "clock.fill",
                        color: .blue
                    )
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var subjectProgressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Progress by Subject")
                .font(.title2)
                .fontWeight(.bold)
            
            ForEach(dataManager.progress.sorted(by: { $0.totalPoints > $1.totalPoints })) { progress in
                SubjectProgressCard(progress: progress)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Progress Yet")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Complete some homework problems to see your progress here!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct SubjectProgressCard: View {
    let progress: UserProgress
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(progress.subject)
                    .font(.headline)
                
                Spacer()
                
                Text("\(progress.totalPoints) pts")
                    .font(.subheadline)
                    .foregroundColor(.orange)
            }
            
            HStack(spacing: 24) {
                VStack(alignment: .leading) {
                    Text("Problems Solved")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(progress.problemsSolved)")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                VStack(alignment: .leading) {
                    Text("Avg Score")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f", progress.averageScore))
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}
