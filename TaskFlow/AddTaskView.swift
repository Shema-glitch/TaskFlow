import SwiftUI

struct AddTaskView: View {
    let categories: [TaskCategory]
    var onAdd: (TodoTask) -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var title = ""
    @State private var date = Date()
    @State private var note = ""
    @State private var selectedCategory: String = "Work"
    @State private var selectedPriority: TaskPriority = .medium

    private func updatePredictions() {
        let predictedPriority = AIPriorityPredictor.predictPriority(from: title)
        selectedPriority = predictedPriority
        recurrence = AIRecurrencePredictor.predictRecurrence(from: title)
        selectedCategory = AICategoryPredictor.predictCategory(from: title)

        // Automatically enable reminder for high priority tasks
        hasReminder = predictedPriority == .high || AIReminderPredictor.shouldSetReminder(from: title)

        if let predictedDate = AIDatePredictor.predictDate(from: title) {
            date = predictedDate
        }
    }
    @State private var hasReminder = false
    @State private var recurrence: TaskRecurrence = .none

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task")) {
                    VStack(alignment: .leading) {
                        TextField("What are you planning?", text: $title)
                            .onChange(of: title) { _ in
                                updatePredictions()
                            }

                        if !title.isEmpty {
                            let suggestions = AITaskSuggester.getSuggestions(for: title)
                            if !suggestions.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(suggestions, id: \.self) { suggestion in
                                            Button(action: {
                                                title = "\(title.split(separator: " ").first ?? "") \(suggestion)"
                                            }) {
                                                Text(suggestion)
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 5)	
                                                    .background(Color.blue.opacity(0.1))
                                                    .cornerRadius(8)
                                            }
                                        }
                                    }
                                }
                                .padding(.top, 5)
                            }
                        }
                    }
                }
                Section(header: Text("Date & Time")) {
                    DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
                        .labelsHidden()
                    Toggle("Set Reminder", isOn: $hasReminder)
                }
                Section(header: Text("Category")) {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories) { cat in
                            Text(cat.name).tag(cat.name)
                        }
                    }
                }
                Section(header: Text("Priority")) {
                    Picker("Priority", selection: $selectedPriority) {
                        ForEach(TaskPriority.allCases) { p in
                            Text(p.rawValue).tag(p)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                Section(header: Text("Recurrence")) {
                    Picker("Repeat", selection: $recurrence) {
                        ForEach(TaskRecurrence.allCases) { r in
                            Text(r.rawValue).tag(r)
                        }
                    }
                }
                Section(header: Text("Note")) {
                    TextField("Add note", text: $note)
                }

                VStack {
                    Button(action: {
                        do {
                            if VoiceCommandManager.shared.isRecording {
                                VoiceCommandManager.shared.stopRecording()
                            } else {
                                try VoiceCommandManager.shared.startRecording()
                                VoiceCommandManager.shared.onCommandRecognized = { command in
                                    title = command
                                    updatePredictions()
                                }
                            }
                        } catch {
                            print("Recording error: \(error.localizedDescription)")
                        }
                    }) {
                        Label(VoiceCommandManager.shared.isRecording ? "Stop Recording" : "Add by Voice",
                              systemImage: VoiceCommandManager.shared.isRecording ? "stop.circle.fill" : "mic.fill")
                            .font(.headline)
                            .padding()
                            .background(VoiceCommandManager.shared.isRecording ? Color.red.opacity(0.2) : Color.blue.opacity(0.2))
                            .clipShape(Capsule())
                    }
                    .foregroundColor(VoiceCommandManager.shared.isRecording ? .red : .blue)

                    if VoiceCommandManager.shared.isRecording {
                        Text(VoiceCommandManager.shared.transcribedText)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }

                    if let error = VoiceCommandManager.shared.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 4)
                    }
                }
            }
            .navigationBarTitle("New Task", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Create") {
                let newTask = TodoTask(title: title, date: date, category: selectedCategory, isDone: false, priority: selectedPriority, note: note.isEmpty ? nil : note, hasReminder: hasReminder, recurrence: recurrence)
                onAdd(newTask)
                presentationMode.wrappedValue.dismiss()
            }.disabled(title.isEmpty))
        }
    }
}
