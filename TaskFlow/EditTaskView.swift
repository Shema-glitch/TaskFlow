
import SwiftUI

struct EditTaskView: View {
    @Binding var task: TodoTask?
    let categories: [TaskCategory]
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title: String = ""
    @State private var date: Date = Date()
    @State private var note: String = ""
    @State private var selectedCategory: String = ""
    @State private var selectedPriority: TaskPriority = .medium
    @State private var hasReminder: Bool = false
    @State private var recurrence: TaskRecurrence = .none
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task")) {
                    TextField("Task title", text: $title)
                }
                
                Section(header: Text("Date & Time")) {
                    DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
                        .labelsHidden()
                    Toggle("Set Reminder", isOn: $hasReminder)
                }
                
                Section(header: Text("Category")) {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories) { category in
                            Text(category.name).tag(category.name)
                        }
                    }
                }
                
                Section(header: Text("Priority")) {
                    Picker("Priority", selection: $selectedPriority) {
                        ForEach(TaskPriority.allCases) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Recurrence")) {
                    Picker("Repeat", selection: $recurrence) {
                        ForEach(TaskRecurrence.allCases) { recurrence in
                            Text(recurrence.rawValue).tag(recurrence)
                        }
                    }
                }
                
                Section(header: Text("Note")) {
                    TextField("Add note", text: $note)
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    task?.title = title
                    task?.date = date
                    task?.category = selectedCategory
                    task?.priority = selectedPriority
                    task?.note = note.isEmpty ? nil : note
                    task?.hasReminder = hasReminder
                    task?.recurrence = recurrence
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .onAppear {
                if let task = task {
                    title = task.title
                    date = task.date
                    selectedCategory = task.category
                    selectedPriority = task.priority
                    note = task.note ?? ""
                    hasReminder = task.hasReminder
                    recurrence = task.recurrence
                }
            }
        }
    }
}
