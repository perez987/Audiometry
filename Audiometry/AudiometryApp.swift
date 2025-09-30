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
            
                .onAppear {
                    // Set initial window title
                    DispatchQueue.main.async {
                        if let window = NSApplication.shared.windows.first {
                            window.title = languageManager.localizedString(for: "app_title")
                        }
                    }
                }
            
                .onChange(of: languageManager.currentLanguage) { _ in
                    // Force window title update when language changes
                    // Delegate window title update to AppDelegate to avoid ordering issues
                    DispatchQueue.main.async {
                        appDelegate.updateWindowTitle()
                    }
                }
            
        }
        
        .windowStyle(DefaultWindowStyle())
        .windowResizability(.contentSize)
        
    }
    
}
