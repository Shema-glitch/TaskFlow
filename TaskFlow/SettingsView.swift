
import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name("ThemeChanged"), object: nil)
        }
    }
    @AppStorage("useHaptics") private var useHaptics = true
    @AppStorage("showQuotes") private var showQuotes = true
    @AppStorage("sortTasksBy") private var sortTasksBy = "date"
    @AppStorage("defaultPriority") private var defaultPriority = "medium"
    @State private var showResetConfirmation = false
    @State private var showExportData = false
    
    private let appVersion = "1.0.0"
    private let buildNumber = "100"
    private let socialLinks = [
        ("Twitter", "square.and.arrow.up", "https://x.com/ShemaCharmant"),
        ("GitHub", "terminal.fill", "https://github.com/Shema-glitch"),
        ("LinkedIn", "person.crop.square.filled.and.at.rectangle", "https://www.linkedin.com/in/shema-charmant-73abb433a/?trk=opento_sprofile_details"),
        ("Portfolio", "globe", "https://yourwebsite.com"),
        ("Email", "envelope.fill", "mailto:charmantshema112@gmail.com")
    ]
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("App Preferences")) {
                    Toggle(isOn: $isDarkMode) {
                        Label("Dark Mode", systemImage: "moon.fill")
                    }
                    
                    Toggle(isOn: $showQuotes) {
                        Label("Motivational Quotes", systemImage: "text.quote")
                    }
                    
                    Toggle(isOn: $useHaptics) {
                        Label("Haptic Feedback", systemImage: "hand.tap")
                    }
                }
                
                Section(header: Text("Task Defaults")) {
                    Picker("Sort Tasks By", selection: $sortTasksBy) {
                        Text("Date").tag("date")
                        Text("Priority").tag("priority")
                        Text("Alphabetical").tag("alpha")
                    }
                    .pickerStyle(.menu)
                    
                    Picker("Default Priority", selection: $defaultPriority) {
                        Text("High").tag("high")
                        Text("Medium").tag("medium")
                        Text("Low").tag("low")
                    }
                    .pickerStyle(.menu)
                }
                
                Section(header: Text("Data Management")) {
                    Button(action: { showExportData = true }) {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(role: .destructive, action: { showResetConfirmation = true }) {
                        Label("Reset All Data", systemImage: "trash")
                    }
                }
                
                Section(header: Text("App Info")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("\(appVersion) (\(buildNumber))")
                            .foregroundColor(.secondary)
                    }
                    
                    NavigationLink(destination: CreditsView()) {
                        Label("Credits & Acknowledgments", systemImage: "info.circle")
                    }
                    
                    NavigationLink(destination: PrivacyView()) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }
                }
                
                Section(header: Text("Connect")) {
                    ForEach(socialLinks, id: \.0) { name, icon, url in
                        Link(destination: URL(string: url)!) {
                            Label(name, systemImage: icon)
                        }
                    }
                }
                
                Section(header: Text("Support")) {
                    Button(action: { reportBug() }) {
                        Label("Report a Bug", systemImage: "ant")
                    }
                    
                    Button(action: { requestFeature() }) {
                        Label("Request a Feature", systemImage: "star")
                    }
                    
                    Link(destination: URL(string: "https://your-app-store-link.com")!) {
                        Label("Rate the App", systemImage: "star.bubble")
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Reset Data", isPresented: $showResetConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("Are you sure you want to reset all data? This action cannot be undone.")
            }
        }
    }
    
    private func resetAllData() {
        // Implement data reset functionality
    }
    
    private func reportBug() {
        if let url = URL(string: "mailto:charmantshema112@gmail.com?subject=Bug%20Report") {
            UIApplication.shared.open(url)
        }
    }
    
    private func requestFeature() {
        if let url = URL(string: "mailto:charmantshema112@gmail.com?subject=Feature%20Request") {
            UIApplication.shared.open(url)
        }
    }
}

struct PrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy")
                    .font(.title)
                    .bold()
                
                Text("Last updated: \(Date().formatted(date: .long, time: .omitted))")
                    .foregroundColor(.secondary)
                
                Text("Your privacy is important to us. This app does not collect any personal information. All your tasks and data are stored locally on your device.")
                    .padding(.vertical)
                
                Text("Data Storage")
                    .font(.headline)
                Text("• All tasks and settings are stored locally\n• No data is transmitted to external servers\n• Your data is never shared with third parties")
                
                Text("Permissions")
                    .font(.headline)
                Text("• Notifications: Used for task reminders\n• Calendar: Used for task scheduling")
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
