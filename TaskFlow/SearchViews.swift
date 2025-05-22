import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    @Binding var isSearching: Bool

    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)

                TextField("Search tasks...", text: $text)
                    .onChange(of: text) { _ in
                        isSearching = !text.isEmpty
                    }

                if !text.isEmpty {
                    Button(action: {
                        text = ""
                        isSearching = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
}

struct GlobalSearchResultsView: View {
    let tasks: [TodoTask]
    @State private var selectedTask: TodoTask?

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                ForEach(tasks) { task in
                    TaskCardView(task: task)
                        .onTapGesture {
                            selectedTask = task
                        }
                }
            }
        }
        .sheet(item: $selectedTask) { task in
            TaskDetailView(task: task)
        }
    }
}

struct TaskCardView: View {
    let task: TodoTask

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(task.priority.color)
                    .frame(width: 12, height: 12)
                Text(task.title)
                    .font(.headline)
            }

            HStack {
                Image(systemName: "folder.fill")
                    .foregroundColor(.secondary)
                Text(task.category)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                Text(task.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if let note = task.note {
                Text(note)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

// TaskDetailView and DetailRow are now imported from SharedViews.swift

// Remove the duplicate extension as it's already in Models.swift
// extension TaskPriority {
//     var color: Color {
//         switch self {
//         case .high: return .red
//         case .medium: return .orange
//         case .low: return .green
//         }
//     }
// }
