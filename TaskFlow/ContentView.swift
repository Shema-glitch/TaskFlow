import SwiftUI
import UserNotifications
import CoreHaptics

// MARK: - Content View
struct ContentView: View {
    // MARK: - Haptics
    @State private var engine: CHHapticEngine?
    
    // MARK: - State Properties
    @State private var categories: [TaskCategory] = TaskCategory.loadCategories() ?? [
        //    @State private var categories = [
        TaskCategory(
            name: "Work",
            icon: "briefcase.fill",
            color: "#FF9500",  // Orange
            taskCount: 0,
            completedCount: 0
        ),
        TaskCategory(
            name: "Personal",
            icon: "person.fill",
            color: "#FF2D55",  // Pink
            taskCount: 0,
            completedCount: 0
        ),
        TaskCategory(
            name: "Music",
            icon: "music.note",
            color: "#BF5AF2",  // Purple
            taskCount: 0,
            completedCount: 0
        ),
        TaskCategory(
            name: "Travel",
            icon: "airplane",
            color: "#32D74B",  // Green
            taskCount: 0,
            completedCount: 0
        ),
        TaskCategory(
            name: "Study",
            icon: "book.fill",
            color: "#5E5CE6",  // Indigo
            taskCount: 0,
            completedCount: 0
        ),
        TaskCategory(
            name: "Home",
            icon: "house.fill",
            color: "#FF3B30",  // Red
            taskCount: 0,
            completedCount: 0
        ),
        TaskCategory(
            name: "Shopping",
            icon: "cart.fill",
            color: "#64D2FF",  // Light Blue
            taskCount: 0,
            completedCount: 0
        ),
        TaskCategory(
            name: "Health",
            icon: "heart.fill",
            color: "#30B0C7",  // Teal
            taskCount: 0,
            completedCount: 0
        ),
        TaskCategory(
            name: "Finance",
            icon: "dollarsign.circle.fill",
            color: "#30D158",  // Mint
            taskCount: 0,
            completedCount: 0
        )
    ]
    
    @State private var tasks: [TodoTask] = {
        if let data = UserDefaults.standard.data(forKey: "savedTasks"),
           let decodedTasks = try? JSONDecoder().decode([TodoTask].self, from: data) {
            return decodedTasks
        }
        return []
    }()
    
    @State private var selectedCategory: TaskCategory? = nil
    @State private var showAddTask = false
    @State private var showCalendar = false
    @State private var showAddCategory = false
    @State private var showStatistics = false
    @StateObject private var themeManager = ThemeManager()
    //    @State private var isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var showImportExport = false
    @State private var showSettings = false
    //    @AppStorage("hasSeenTutorial") private var hasSeenTutorial = false // Added state for tutorial
    //    @State private var showingTutorial = false // Added state for tutorial
    
    @AppStorage("hasSeenTutorial") private var hasSeenTutorial = false
    @State private var showingTutorial = false
    @State private var showStarterTemplateAlert = false
    //    @State private var showStarterTemplateAlert = false
    
    private func initializeCategories() {
        categories = []
        TaskCategory.saveCategories(categories)
    }
    
    private func addStarterTemplate() {
        categories = TaskCategory.defaultCategories
        TaskCategory.saveCategories(categories)
    }
    
    // MARK: - Constants
    private let quotes = [
        "The secret of getting ahead is getting started.",
        "Don't watch the clock; do what it does. Keep going.",
        "It always seems impossible until it's done.",
        "Success is the sum of small efforts, repeated day in and day out.",
        "The future depends on what you do today.",
        "You don't have to be great to start, but you have to start to be great."
    ]
    
    // MARK: - Computed Properties
    private var filteredTasks: [TodoTask] {
        if searchText.isEmpty { return tasks }
        return tasks.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    
    private var totalTasks: Int { tasks.count }
    private var completedTasks: Int { tasks.filter { $0.isDone }.count }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            //            .onAppear {
            //                if categories.isEmpty {
            //                    showStarterTemplateAlert = true
            //                }
            //            } // Not working dont uncomment
            ZStack(alignment: .bottomTrailing) {
                GeometryReader { geometry in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            // Search Bar
                            SearchBar(text: $searchText, isSearching: $isSearching)
                                .padding(.horizontal)
                                .padding(.top, 16)
                            
                            if isSearching {
                                GlobalSearchResultsView(tasks: filteredTasks)
                                    .padding(.horizontal)
                            } else {
                                // Quote View with blur effect
                                if UserDefaults.standard.bool(forKey: "showQuotes") {
                                    RollingQuoteView(quotes: quotes)
                                        .padding(.horizontal)
                                        .padding(.top, 8)
                                }
                                // Header with Actions
                                HStack {
                                    Text("Lists")
                                        .font(.largeTitle).bold()
                                    Spacer()
                                    HStack(spacing: 12) {
                                        Button(action: { showCalendar = true }) {
                                            Image(systemName: "calendar")
                                                .font(.system(size: 18))
                                        }
                                        Button(action: { showStatistics = true }) {
                                            Image(systemName: "chart.bar.fill")
                                                .font(.system(size: 18))
                                        }
                                        Button(action: {
                                            themeManager.isDarkMode.toggle()
                                        }) {
                                            Image(systemName: themeManager.isDarkMode ? "sun.max.fill" : "moon.fill")
                                                .font(.system(size: 18))
                                        }
                                        Button(action: { showImportExport = true }) {
                                            Image(systemName: "square.and.arrow.up.on.square")
                                                .font(.system(size: 18))
                                        }
                                        Button(action: { showSettings = true }) {
                                            Image(systemName: "gearshape.fill")
                                                .font(.system(size: 18))
                                        }
                                    }
                                    .padding(8)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(10)
                                }
                                .padding(.horizontal)
                                
                                // Stats and Add Category
                                HStack {
                                    Text("Completed: \(completedTasks)/\(totalTasks) tasks")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .padding(8)
                                        .background(Color.secondary.opacity(0.1))
                                        .cornerRadius(8)
                                    
                                    Spacer()
                                    
                                    Button(action: { showAddCategory = true }) {
                                        Label("Add Category", systemImage: "plus.app")
                                            .font(.subheadline)
                                            .padding(8)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(10)
                                    }
                                }
                                .padding(.horizontal)
                                
                                // Responsive Category Grid
                                let adaptiveColumns = [
                                    GridItem(.adaptive(minimum: 150, maximum: 250), spacing: 20)
                                ]
                                LazyVGrid(columns: adaptiveColumns, spacing: 20) {
                                    ForEach(categories) { category in
                                        CategoryCard(category: category) {
                                            selectedCategory = category
                                        }
                                        .swipeActions(edge: .trailing) {
                                            Button(role: .destructive) {
                                                deleteCategory(category)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                    }
                                }
                                .padding()
                                
                                Spacer(minLength: 80)
                            }
                        }
                    }
                    .background(Color(.systemGroupedBackground))
                }
                
                // Floating Action Button
                Button(action: { showAddTask = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                }
                .padding(24)
            }
            //            .onAppear(perform: prepareHaptics)
            .onAppear {
                if categories.isEmpty {
                    showStarterTemplateAlert = true
                }
            }
            .sheet(item: $selectedCategory) { category in
                TaskListView(category: category, tasks: $tasks)
            }
            .sheet(isPresented: $showAddTask) {
                AddTaskView(categories: categories, onAdd: addNewTask)
            }
            .sheet(isPresented: $showAddCategory) {
                AddCategoryView(categories: $categories)
            }
            .sheet(isPresented: $showCalendar) {
                CalendarTaskView(tasks: tasks)
            }
            .sheet(isPresented: $showStatistics) {
                StatisticsView(tasks: tasks)
            }
            .sheet(isPresented: $showImportExport) {
                ImportExportView(tasks: $tasks)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            //            .onAppear(perform: prepareHaptics)
            //            .overlay {
            //                if !hasSeenTutorial && showingTutorial {
            //                    TutorialOverlay(isShowing: $showingTutorial, onComplete: {
            //                        hasSeenTutorial = true
            //                    })
            //                }
            //            }
            //            .onAppear {
            //                if !hasSeenTutorial {
            //                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            //                        withAnimation {
            //                            showingTutorial = true
            //                        }
            //                    }
            //                }
            //            }
            //            .onChange(of: tasks) { _ in
            //                updateCategoryStats()
            //                saveTasks()
            //            }
            .onAppear {
                prepareHaptics()
                initializeCategories()
            }
            .onChange(of: tasks) { _ in
                updateCategoryStats()
                saveTasks()
            }
            .alert("Welcome to TaskFlow!", isPresented: $showStarterTemplateAlert) {
                Button("Use Starter Template") {
                    addStarterTemplate()
                    TaskCategory.saveCategories(categories)
                }
                Button("Start Fresh", role: .cancel) {
                    categories = []
                    TaskCategory.saveCategories(categories)
                }
            } message: {
                Text("Would you like to start with our recommended category template or start fresh?")
            }
        }
    }
    
    // MARK: - Methods
    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptics error: \(error.localizedDescription)")
        }
    }
    
    private func playReminderHaptic() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()
        let intensities = [0.6, 0.4, 0.6, 0.4]
        let sharpnesses = [0.5, 0.3, 0.5, 0.3]
        var timeOffset = 0.0
        
        for i in 0..<4 {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(intensities[i]))
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(sharpnesses[i]))
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: timeOffset)
            events.append(event)
            timeOffset += 0.15
        }
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription)")
        }
    }
    
    private func updateCategoryStats() {
        for i in categories.indices {
            let categoryTasks = tasks.filter { $0.category == categories[i].name }
            categories[i].taskCount = categoryTasks.count
            categories[i].completedCount = categoryTasks.filter { $0.isDone }.count
        }
    }
    
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: "savedTasks")
        }
    }
    
    private func addNewTask(_ task: TodoTask) {
        tasks.append(task)
        if task.hasReminder {
            scheduleNotification(for: task)
        }
    }
    
    private func deleteCategory(_ category: TaskCategory) {
        withAnimation {
            tasks.removeAll { $0.category == category.name }
            categories.removeAll { $0.id == category.id }
            saveTasks()
        }
    }
    
    private func scheduleNotification(for task: TodoTask) {
        playReminderHaptic()
        let content = UNMutableNotificationContent()
        content.title = "Reminder: \(task.title)"
        content.body = task.note ?? "You have a task due."
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("DEBUG: Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Preview
#Preview {
    Group {
        ContentView()
            .previewDevice("iPhone SE (3rd generation)")
        ContentView()
            .previewDevice("iPhone 15")
    }
}
