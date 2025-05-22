//
//  ThemeManager.swift
//  To-Do App
//
//  Created by Shema Charmant on 5/4/25.
//


import SwiftUI

class ThemeManager: ObservableObject {
    @Published var themeChanged = false
    
    func updateTheme() {
        themeChanged.toggle()
        objectWillChange.send()
        NotificationCenter.default.post(name: NSNotification.Name("ThemeUpdated"), object: nil)
    }
}
