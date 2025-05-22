
import SwiftUI

struct TaskRow: View {
    let task: TodoTask
    
    var body: some View {
        HStack {
            Text(task.title)
            Spacer()
            if task.isDone {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
    }
}

struct DropViewDelegate: DropDelegate {
    let destinationTask: TodoTask
    @Binding var draggedTask: TodoTask?
    @Binding var tasks: [TodoTask]
    
    func performDrop(info: DropInfo) -> Bool {
        guard let draggedTask = self.draggedTask else { return false }
        if let fromIndex = tasks.firstIndex(where: { $0.id == draggedTask.id }),
           let toIndex = tasks.firstIndex(where: { $0.id == destinationTask.id }) {
            withAnimation {
                let task = tasks.remove(at: fromIndex)
                tasks.insert(task, at: toIndex)
            }
        }
        return true
    }
}

struct TaskListView: View {
    let category: TaskCategory
    @Binding var tasks: [TodoTask]
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    @State private var filter: TaskFilter = .all
    @State private var sortOption: SortOption = .date
    @State private var selectedTask: TodoTask?
    @State private var showingShareSheet = false
    @State private var showEditTask = false
    @State private var editingTask: TodoTask?
    @State private var draggedTask: TodoTask?

    enum SortOption: String, CaseIterable, Identifiable {
        case date = "Date"
        case priority = "Priority"
        case title = "Title"
        var id: String { self.rawValue }
    }

    enum TaskFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case active = "Active"
        case completed = "Completed"
        var id: String { self.rawValue }
    }

    var filteredTasks: [TodoTask] {
        tasks.filter { $0.category == category.name }
            .filter { task in
                searchText.isEmpty || task.title.localizedCaseInsensitiveContains(searchText) ||
                (task.note?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
            .filter { task in
                switch filter {
                case .all: return true
                case .active: return !task.isDone
                case .completed: return task.isDone
                }
            }
    }

    func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: "savedTasks")
        }
    }

    func updateCategoryStats() {
        // This function would update category statistics
        // Implementation depends on how you manage categories
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .padding(.trailing, 8)
                }
                Text(category.name)
                    .font(.largeTitle).bold()
                Spacer()
            }
            .padding()

            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search tasks...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding([.horizontal, .bottom])

            Picker("Filter", selection: $filter) {
                ForEach(TaskFilter.allCases) { f in
                    Text(f.rawValue).tag(f)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding([.horizontal, .bottom])

            List {
                ForEach(filteredTasks) { task in
                    TaskRow(task: task)
                        .onDrag {
                            self.draggedTask = task
                            return NSItemProvider(object: task.id.uuidString as NSString)
                        }
                        .onDrop(of: [.text], delegate: DropViewDelegate(destinationTask: task, draggedTask: $draggedTask, tasks: $tasks))
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                if let idx = tasks.firstIndex(where: { $0.id == task.id }) {
                                    tasks[idx].isDone.toggle()
                                    saveTasks()
                                    updateCategoryStats()
                                }
                            } label: {
                                Label(task.isDone ? "Uncomplete" : "Complete", systemImage: task.isDone ? "arrow.uturn.left" : "checkmark")
                            }
                            .tint(task.isDone ? .gray : .green)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                if let idx = tasks.firstIndex(where: { $0.id == task.id }) {
                                    tasks.remove(at: idx)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
    }

    func priorityColor(_ priority: TaskPriority) -> Color {
        switch priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .blue
        }
    }
}
