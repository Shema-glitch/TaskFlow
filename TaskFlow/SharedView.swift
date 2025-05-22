//
//  SharedView.swift
//  To-Do App
//
//  Created by Shema Charmant on 5/10/25.
//
import SwiftUI

// This file contains shared view components that are used across multiple files

struct TaskDetailView: View {
    let task: TodoTask

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Circle()
                    .fill(task.priority.color)
                    .frame(width: 16, height: 16)
                Text(task.title)
                    .font(.title2)
                    .bold()
            }

            GroupBox {
                VStack(alignment: .leading, spacing: 12) {
                    DetailRow(icon: "calendar", title: "Due Date", value: task.date.formatted())
                    DetailRow(icon: "folder.fill", title: "Category", value: task.category)
                    DetailRow(icon: "exclamationmark.circle", title: "Priority", value: task.priority.rawValue)
                    if task.recurrence != .none {
                        DetailRow(icon: "repeat", title: "Recurrence", value: task.recurrence.rawValue)
                    }
                }
            }

            if let note = task.note {
                GroupBox("Notes") {
                    Text(note)
                        .font(.body)
                }
            }

            Spacer()
        }
        .padding()
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
        }
    }
}
