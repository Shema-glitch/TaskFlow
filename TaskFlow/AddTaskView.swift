import SwiftUI
import AVFoundation

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

                VStack(spacing: 12) {
                    // Info text about voice commands
                    Text("Speak your task naturally - I'll understand categories, priorities, and dates!")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    VStack(spacing: 8) {
                        Button(action: {
                            do {
                                if VoiceCommandManager.shared.isRecording {
                                    VoiceCommandManager.shared.stopRecording()
                                } else {
                                    // Reset any previous errors
                                    VoiceCommandManager.shared.errorMessage = nil
                                    try AVAudioSession.sharedInstance().setCategory(.record, mode: .measurement, options: .duckOthers)
                                    try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
                                    try VoiceCommandManager.shared.startRecording()
                                    
                                    // Provide immediate feedback
                                    let impact = UIImpactFeedbackGenerator(style: .medium)
                                    impact.impactOccurred()
                                    
                                    VoiceCommandManager.shared.onCommandRecognized = { command in
                                        title = command
                                        updatePredictions()
                                        
                                        // Provide success feedback
                                        let notification = UINotificationFeedbackGenerator()
                                        notification.notificationOccurred(.success)
                                    }
                                }
                            } catch {
                                VoiceCommandManager.shared.errorMessage = "Unable to start recording: \(error.localizedDescription)"
                                let notification = UINotificationFeedbackGenerator()
                                notification.notificationOccurred(.error)
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: VoiceCommandManager.shared.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                                    .font(.system(size: 20))
                                Text(VoiceCommandManager.shared.isRecording ? "Stop" : "Voice Input")
                                    .font(.subheadline)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(VoiceCommandManager.shared.isRecording ? Color.red.opacity(0.2) : Color.blue.opacity(0.2))
                            .clipShape(Capsule())
                            .overlay(
                                Group {
                                    if VoiceCommandManager.shared.isRecording {
                                        Capsule()
                                            .stroke(Color.red, lineWidth: 2)
                                            .scaleEffect(1.1)
                                            .opacity(0.8)
                                            .animation(
                                                Animation.easeInOut(duration: 0.8)
                                                    .repeatForever(autoreverses: true),
                                                value: VoiceCommandManager.shared.isRecording
                                            )
                                    }
                                }
                            )
                        }
                        .foregroundColor(VoiceCommandManager.shared.isRecording ? .red : .blue)
                        
                        if VoiceCommandManager.shared.isRecording {
                            // Visual feedback for recording
                            HStack(spacing: 4) {
                                ForEach(0..<3) { index in
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 4, height: 4)
                                        .opacity(0.8)
                                        .animation(
                                            Animation.easeInOut(duration: 0.6)
                                                .repeatForever()
                                                .delay(Double(index) * 0.2),
                                            value: VoiceCommandManager.shared.isRecording
                                        )
                                }
                            }
                            .padding(.top, 4)
                            
                            Text(VoiceCommandManager.shared.transcribedText.isEmpty ? "Listening..." : VoiceCommandManager.shared.transcribedText)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .padding(.top, 2)
                        }
                    }

                    if let error = VoiceCommandManager.shared.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 2)
                    }
                    
                    // Example commands
                    if !VoiceCommandManager.shared.isRecording {
                        VStack(spacing: 4) {
                            Text("Try saying:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\"Buy groceries tomorrow morning\"")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("\"High priority meeting with team at 2pm\"")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 8)
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
