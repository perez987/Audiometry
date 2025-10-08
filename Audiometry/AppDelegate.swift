
//
//  AppDelegate.swift
//
//  Created by GitHub Copilot on 20/09/2025.
//  Modified by perez987 on 20/09/2025.
//

import AppKit
import Foundation
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_: Notification) {
        // Ensure the application is active before manipulating windows
        NSApp.activate(ignoringOtherApps: true)
        
        // Set initial window title after activation
        DispatchQueue.main.async {
            self.updateWindowTitle()
        }
    }
    
    func applicationDidBecomeActive(_: Notification) {
        // Update window title when app becomes active
        updateWindowTitle()
    }
        
//    func viewDidLoad() {
//    }

    // Close app from red button (thanks chris1111)
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        return true
    }
    
    // Helper method to safely update window title
    func updateWindowTitle() {
        guard NSApp.isActive else { return }
        
        if let window = NSApplication.shared.windows.first {
            window.title = LanguageManager.shared.localizedString(for: "app_title")
        }
    }
    
//    func applicationWillTerminate(_ aNotification: Notification) {
//
//    }
    
}
