import SwiftUI

struct TaskCategory: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var icon: String
    var color: String
    var taskCount: Int
    var completedCount: Int
    var isCustom: Bool

    static let defaultCategories: [TaskCategory] = [
        TaskCategory(name: "Work", icon: "briefcase.fill", color: "#FF0000", taskCount: 0, completedCount: 0, isCustom: false),
        TaskCategory(name: "Personal", icon: "person.fill", color: "#00FF00", taskCount: 0, completedCount: 0, isCustom: false),
        TaskCategory(name: "Shopping", icon: "cart.fill", color: "#0000FF", taskCount: 0, completedCount: 0, isCustom: false),
        TaskCategory(name: "Health", icon: "heart.fill", color: "#FF00FF", taskCount: 0, completedCount: 0, isCustom: false),
        TaskCategory(name: "Study", icon: "book.fill", color: "#FFFF00", taskCount: 0, completedCount: 0, isCustom: false)
    ]

    static func saveCategories(_ categories: [TaskCategory]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(categories) {
            UserDefaults.standard.set(encoded, forKey: "savedCategories")
            UserDefaults.standard.synchronize()
        }
    }

    static func loadCategories() -> [TaskCategory] {
        if let data = UserDefaults.standard.data(forKey: "savedCategories"),
           let decoded = try? JSONDecoder().decode([TaskCategory].self, from: data) {
            return decoded
        }
        return defaultCategories
    }

    static func deleteCategory(_ category: TaskCategory, from categories: inout [TaskCategory]) {
        if category.isCustom {
            categories.removeAll { $0.id == category.id }
            saveCategories(categories)
        }
    }

    var displayColor: Color {
        Color(hex: color) ?? .blue
    }

    init(id: UUID = UUID(), name: String, icon: String, color: String, taskCount: Int = 0, completedCount: Int = 0, isCustom: Bool = false) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.taskCount = taskCount
        self.completedCount = completedCount
        self.isCustom = isCustom
    }
}

struct TodoTask: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var date: Date
    var category: String
    var isDone: Bool
    var priority: TaskPriority
    var note: String?
    var hasReminder: Bool
    var recurrence: TaskRecurrence

    init(id: UUID = UUID(), title: String, date: Date, category: String, isDone: Bool = false, priority: TaskPriority, note: String? = nil, hasReminder: Bool = false, recurrence: TaskRecurrence = .none) {
        self.id = id
        self.title = title
        self.date = date
        self.category = category
        self.isDone = isDone
        self.priority = priority
        self.note = note
        self.hasReminder = hasReminder
        self.recurrence = recurrence
    }
}

enum TaskPriority: String, Codable, CaseIterable, Identifiable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
    var id: String { self.rawValue }
}

enum TaskRecurrence: String, Codable, CaseIterable, Identifiable {
    case none = "None"
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    var id: String { self.rawValue }
}

// Color extension for hex support
extension Color {
    init?(hex: String) {
        var str = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if str.hasPrefix("#") {
            str.remove(at: str.startIndex)
        }

        if str.count != 6 {
            return nil
        }

        var rgb: UInt64 = 0
        Scanner(string: str).scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }

    func toHex() -> String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)

        return String(format: "#%02X%02X%02X",
                     Int(r * 255),
                     Int(g * 255),
                     Int(b * 255))
    }
}

extension TaskPriority {
    var color: Color {
        switch self {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }
}

struct AIRecurrencePredictor {
    static func predictRecurrence(from title: String) -> TaskRecurrence {
        let lowercaseTitle = title.lowercased()

        if lowercaseTitle.contains("every day") ||
           lowercaseTitle.contains("daily") {
            return .daily
        }

        if lowercaseTitle.contains("every week") ||
           lowercaseTitle.contains("weekly") {
            return .weekly
        }

        if lowercaseTitle.contains("every month") ||
           lowercaseTitle.contains("monthly") {
            return .monthly
        }

        return .none
    }
}

struct AIPriorityPredictor {
    static let highPriorityPatterns = [
        "urgent", "asap", "important", "critical", "deadline", "due",
        "emergency", "priority", "crucial", "vital", "essential",
        "immediate", "now", "today", "overdue", "needed", "required",
        "must", "necessary", "key", "primary", "top", "first", "quick",
        "rush", "serious", "major", "significant", "chief", "main"
    ]

    static let lowPriorityPatterns = [
        "sometime", "when possible", "eventually", "later",
        "whenever", "no rush", "if possible", "optional",
        "maybe", "consider", "think about", "backlog",
        "future", "pending", "secondary", "minor", "trivial",
        "casual", "flexible", "relaxed", "can wait", "not urgent",
        "someday", "unimportant", "low", "minimal"
    ]

    static func predictPriority(from title: String) -> TaskPriority {
        let lowercaseTitle = title.lowercased()
        var score = 0

        // Context-based scoring
        if lowercaseTitle.contains("meeting") && lowercaseTitle.contains("client") {
            score += 3
        }
        if lowercaseTitle.contains("deadline") && lowercaseTitle.contains("tomorrow") {
            score += 4
        }

        // Word-based scoring
        for pattern in highPriorityPatterns where lowercaseTitle.contains(pattern) {
            score += 2
        }
        for pattern in lowPriorityPatterns where lowercaseTitle.contains(pattern) {
            score -= 2
        }

        // Time-based scoring
        if lowercaseTitle.contains("today") || lowercaseTitle.contains("tomorrow") {
            score += 1
        }

        if score >= 3 { return .high }
        if score <= -2 { return .low }
        return .medium
    }
}
struct AIDatePredictor {
    static func predictDate(from title: String) -> Date? {
        let lowercaseTitle = title.lowercased()
        let calendar = Calendar.current
        let now = Date()

        // Today
        if lowercaseTitle.contains("today") {
            return now
        }

        // Tomorrow
        if lowercaseTitle.contains("tomorrow") {
            return calendar.date(byAdding: .day, value: 1, to: now)
        }

        // Next week
        if lowercaseTitle.contains("next week") {
            return calendar.date(byAdding: .weekOfYear, value: 1, to: now)
        }

        // This weekend
        if lowercaseTitle.contains("weekend") {
            let weekday = calendar.component(.weekday, from: now)
            let daysUntilWeekend = 7 - weekday
            return calendar.date(byAdding: .day, value: daysUntilWeekend, to: now)
        }

        return nil
    }
}

struct AICategoryPredictor {
    static let categoryKeywords: [String: Set<String>] = [
        "Work": ["meeting", "project", "email", "presentation", "client",
                "report", "deadline", "conference", "proposal", "budget",
                "interview", "office", "collaborate", "team", "business",
                "schedule", "plan", "strategy", "review", "document"],

        "Study": ["study", "homework", "research", "exam", "assignment",
                 "lecture", "class", "course", "reading", "practice",
                 "test", "quiz", "learn", "study group", "tutorial",
                 "workshop", "seminar", "paper", "thesis", "project"],

        "Home": ["clean", "cook", "laundry", "shopping", "groceries",
                "repair", "organize", "garden", "maintenance", "declutter",
                "bills", "chores", "dishes", "vacuum", "trash",
                "furniture", "decoration", "renovation", "yard", "storage"],

        "Health": ["exercise", "workout", "gym", "doctor", "medication",
                  "appointment", "diet", "nutrition", "meditation", "yoga",
                  "running", "swimming", "therapy", "checkup", "dentist"],

        "Social": ["party", "dinner", "meet", "friend", "family",
                  "gathering", "celebration", "event", "birthday", "coffee",
                  "lunch", "date", "reunion", "visit", "hangout"],

        "Travel": ["flight", "trip", "travel", "pack", "booking",
                  "hotel", "reservation", "passport", "visa", "itinerary",
                  "vacation", "journey", "explore", "adventure", "tour"],

        "Finance": ["bank", "payment", "budget", "invest", "tax",
                   "insurance", "savings", "expense", "invoice", "bill",
                   "account", "credit", "debt", "financial", "money"],

        "Entertainment": ["movie", "game", "show", "concert", "book",
                        "music", "play", "festival", "theater", "art",
                        "hobby", "stream", "watch", "listen", "read"]
    ]

    static func predictCategory(from title: String) -> String {
        let lowercaseTitle = title.lowercased()
        var categoryScores: [String: Int] = [:]

        for (category, keywords) in categoryKeywords {
            let score = keywords.reduce(0) { count, keyword in
                lowercaseTitle.contains(keyword) ? count + 1 : count
            }
            if score > 0 {
                categoryScores[category] = score
            }
        }

        // Return the category with the highest score, or "Other" if no matches
        return categoryScores.max(by: { $0.value < $1.value })?.key ?? "Other"
    }
}

struct AIReminderPredictor {
    static func shouldSetReminder(from title: String) -> Bool {
        let lowercaseTitle = title.lowercased()

        // Time-related keywords that suggest a reminder might be needed
        let reminderKeywords = [
            "remember", "remind", "don't forget",
            "tomorrow", "tonight", "morning",
            "afternoon", "evening", "later",
            "meeting", "appointment", "call",
            "deadline", "due"
        ]

        return reminderKeywords.contains { keyword in
            lowercaseTitle.contains(keyword)
        }
    }
}

struct AITaskSuggester {
    static let suggestions: [String: [String]] = [
        "buy": ["groceries", "gifts", "clothes", "food", "supplies", "equipment", "books", "tickets", "medicine", "electronics"],
        "call": ["doctor", "client", "mom", "dentist", "bank", "insurance", "colleague", "manager", "restaurant", "support"],
        "meet": ["team", "client", "doctor", "friend", "mentor", "partner", "professor", "contractor", "family", "group"],
        "review": ["documents", "code", "presentation", "report", "contract", "proposal", "budget", "design", "essay", "requirements"],
        "write": ["report", "email", "blog post", "documentation", "proposal", "letter", "article", "notes", "summary", "plan"],
        "prepare": ["presentation", "meeting notes", "dinner", "documents", "report", "speech", "lesson", "materials", "proposal", "agenda"],
        "organize": ["files", "desk", "closet", "meeting", "event", "party", "workshop", "documents", "photos", "schedule"],
        "schedule": ["appointment", "meeting", "interview", "delivery", "pickup", "maintenance", "service", "consultation", "visit", "call"],
        "create": ["document", "presentation", "design", "plan", "budget", "timeline", "proposal", "report", "artwork", "template"],
        "update": ["documentation", "schedule", "budget", "plan", "profile", "records", "inventory", "status", "information", "settings"]
    ]

    static func getSuggestions(for input: String) -> [String] {
        let words = input.lowercased().split(separator: " ")
        guard let firstWord = words.first else { return [] }

        // Get direct matches
        var results = suggestions[String(firstWord)] ?? []

        // Get context-aware suggestions
        if words.count > 1 {
            let context = words.dropFirst().joined(separator: " ")
            results = results.filter { suggestion in
                !suggestion.contains(context) // Avoid duplicates
            }
        }

        // Limit suggestions to prevent overwhelming
        return Array(results.prefix(5))
    }
}
