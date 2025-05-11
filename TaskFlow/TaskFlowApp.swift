//
//  TaskFlowApp.swift
//  TaskFlow
//
//  Created by Shema Charmant on 5/11/25.
//

import SwiftUI

@main
struct TaskFlowApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
