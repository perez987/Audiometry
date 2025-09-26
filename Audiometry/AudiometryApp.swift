//
//  AudiometryApp.swift
//  Audiometry
//
//  Created by perez987 on 2025/09/25.
//

import SwiftUI
import CoreData

@main
struct AudiometryApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .windowStyle(DefaultWindowStyle())
        .windowResizability(.contentSize)
    }
}

