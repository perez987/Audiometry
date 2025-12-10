//
//  AudiometryApp.swift
//  Audiometry
//
//  Modified by perez987 on 20/09/2025.
//

import SwiftUI
import AppKit

@main
struct AudiometryApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @ObservedObject private var languageManager = LanguageManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
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
