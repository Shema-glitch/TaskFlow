
import SwiftUI

struct StatisticsView: View {
    let tasks: [TodoTask]

    var completionRate: Double {
        guard !tasks.isEmpty else { return 0 }
        return Double(tasks.filter { $0.isDone }.count) / Double(tasks.count)
    }

    var priorityDistribution: [(TaskPriority, Int)] {
        let grouped = Dictionary(grouping: tasks) { $0.priority }
        return TaskPriority.allCases.map { priority in
            (priority, grouped[priority]?.count ?? 0)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Completion Rate
                VStack(alignment: .leading) {
                    Text("Overall Progress")
                        .font(.headline)
                    ProgressView(value: completionRate)
                        .tint(.blue)
                    Text("\(Int(completionRate * 100))% Complete")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)

                // Category Performance
                CategoryPerformanceView(tasks: tasks)

                // Priority Distribution
                VStack(alignment: .leading) {
                    Text("Priority Distribution")
                        .font(.headline)
                    ForEach(priorityDistribution, id: \.0) { priority, count in
                        HStack {
                            Text(priority.rawValue)
                            Spacer()
                            Text("\(count)")
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
            .padding()
        }
        .navigationTitle("Statistics")
    }
}

struct CategoryPerformanceView: View {
    let tasks: [TodoTask]
    
    var categoryStats: [(String, Int, Int)] {
        let grouped = Dictionary(grouping: tasks) { $0.category }
        return grouped.map { category, tasks in
            (category, tasks.count, tasks.filter { $0.isDone }.count)
        }.sorted { $0.1 > $1.1 }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Category Performance")
                .font(.headline)
                .padding(.bottom, 8)
            
            ForEach(categoryStats, id: \.0) { category, total, completed in
                CategoryProgressRow(
                    name: category,
                    completed: completed,
                    total: total
                )
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

struct CategoryProgressRow: View {
    let name: String
    let completed: Int
    let total: Int
    
    var progress: Double {
        total > 0 ? Double(completed) / Double(total) : 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(name)
                    .font(.subheadline)
                Spacer()
                Text("\(completed)/\(total)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                    
                    Rectangle()
                        .fill(LinearGradient(colors: [.blue, .purple],
                                           startPoint: .leading,
                                           endPoint: .trailing))
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 6)
            .cornerRadius(3)
        }
    }
}

struct DetailedStatsView: View {
    let tasks: [TodoTask]
    
    var body: some View {
        NavigationView {
            List {
                // Add detailed statistics here
                Text("Detailed statistics coming soon")
            }
            .navigationTitle("Detailed Statistics")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
