
import SwiftUI
import UniformTypeIdentifiers

class ImportExportManager {
    static func exportTasks(_ tasks: [TodoTask]) -> Data? {
        try? JSONEncoder().encode(tasks)
    }
    
    static func importTasks(from data: Data) -> [TodoTask]? {
        try? JSONDecoder().decode([TodoTask].self, from: data)
    }
}

struct ImportExportView: View {
    @Binding var tasks: [TodoTask]
    @Environment(\.presentationMode) var presentationMode
    @State private var showingExporter = false
    @State private var showingImporter = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Tasks Management"), footer: Text("Export your tasks to backup or share them. Import tasks from other devices or backups.")) {
                    Button(action: { showingExporter = true }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            VStack(alignment: .leading) {
                                Text("Export Tasks")
                                    .font(.headline)
                                Text("Save tasks as JSON file")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Button(action: { showingImporter = true }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            VStack(alignment: .leading) {
                                Text("Import Tasks")
                                    .font(.headline)
                                Text("Load tasks from JSON file")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Section(header: Text("Information"), footer: Text("Imported tasks will be added to your existing tasks. Make sure to backup your current tasks before importing.")) {
                    HStack {
                        Image(systemName: "info.circle")
                        Text("Current Tasks: \(tasks.count)")
                    }
                }
            }
            .navigationTitle("Import/Export")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .fileExporter(
                isPresented: $showingExporter,
                document: TaskDocument(tasks: tasks),
                contentType: .json,
                defaultFilename: "tasks.json"
            ) { result in
                switch result {
                case .success:
                    alertMessage = "Tasks exported successfully"
                case .failure:
                    alertMessage = "Failed to export tasks"
                }
                showingAlert = true
            }
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: [.json]
            ) { result in
                switch result {
                case .success(let url):
                    if let importedData = try? Data(contentsOf: url),
                       let importedTasks = ImportExportManager.importTasks(from: importedData) {
                        tasks.append(contentsOf: importedTasks)
                        alertMessage = "Tasks imported successfully"
                    } else {
                        alertMessage = "Failed to import tasks"
                    }
                case .failure:
                    alertMessage = "Failed to import tasks"
                }
                showingAlert = true
            }
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Import/Export"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

struct TaskDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    
    var tasks: [TodoTask]
    
    init(tasks: [TodoTask]) {
        self.tasks = tasks
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let tasks = ImportExportManager.importTasks(from: data)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.tasks = tasks
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let data = ImportExportManager.exportTasks(tasks) else {
            throw CocoaError(.fileWriteUnknown)
        }
        return FileWrapper(regularFileWithContents: data)
    }
}
