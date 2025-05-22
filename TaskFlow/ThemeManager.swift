//
//  ThemeManager.swift
//  To-Do App
//
//  Created by Shema Charmant on 5/4/25.
//  Fixed the dark mode
//


import SwiftUI

class ThemeManager: ObservableObject {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false {
        didSet {
            updateTheme()
        }
    }
    
    func updateTheme() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { window in
                window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
            }
        }
    }
}
