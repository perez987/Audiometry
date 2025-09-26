//
//  AudiometryApp.swift
//  Audiometry
//
//  Created by perez987 on 2025/09/25.
//

import SwiftUI

@main
struct AudiometryApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
var body: some Scene {
    WindowGroup {
        ContentView()
        }
    
    .windowStyle(DefaultWindowStyle())
    .windowResizability(.contentSize)
    }
    
}

