import SwiftUI

struct CalendarTaskView: View {
    let tasks: [TodoTask]
    @State private var selectedDate: Date = Date()
    @State private var selectedTask: TodoTask?
    
    var tasksForSelectedDate: [TodoTask] {
        tasks.filter { task in
            Calendar.current.isDate(task.date, inSameDayAs: selectedDate)
        }
    }
    
    var body: some View {
        VStack {
            DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date])
                .datePickerStyle(.graphical)
                .padding()
            
            List(tasksForSelectedDate) { task in
                Button(action: { selectedTask = task }) {
                    HStack {
                        Circle()
                            .fill(task.priority.color) // Fixed to use priority color instead of category
                            .frame(width: 12, height: 12)
                        Text(task.title)
                            .foregroundColor(task.isDone ? .secondary : .primary)
                        Spacer()
                        Text(task.category)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .sheet(item: $selectedTask) { task in
            TaskDetailView(task: task)
        }
    }
}

// Removing the duplicate TaskDetailView since it's defined in SearchViews.swift
// You'll use the unified TaskDetailView from there
