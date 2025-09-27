//
//  AudiometryApp.swift
//  Audiometry
//
//  Created by perez987 on 2025/09/25.
//

import SwiftUI
import CoreData
import AppKit

@main
struct AudiometryApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @ObservedObject private var languageManager = LanguageManager.shared
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .windowStyle(DefaultWindowStyle())
        .windowResizability(.contentSize)
        // Use computed property that responds to language changes
        .onChange(of: languageManager.currentLanguage) { _ in
            // Delegate window title update to AppDelegate to avoid ordering issues
            DispatchQueue.main.async {
                appDelegate.updateWindowTitle()
            }
        }
    }
}
