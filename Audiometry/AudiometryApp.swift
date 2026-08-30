//
//  AudiometryApp.swift
//  Audiometry
//
//  Modified by perez987 on 20/09/2025.
//

import AppKit
import SwiftUI

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

                .onChange(of: languageManager.currentLanguage) { _, _ in
                    // Force window title update when language changes
                    // Delegate window title update to AppDelegate to avoid ordering issues
                    DispatchQueue.main.async {
                        appDelegate.updateWindowTitle()
                    }
                }
                .frame(minWidth: 660, idealWidth: 660, maxWidth: 660, minHeight: 780)
        }

        .windowStyle(DefaultWindowStyle())
        .windowResizability(.contentSize)
    }
}
