//
//  AudiometryApp.swift
//  Audiometry
//
//  Modified by perez987 on 20/09/2025.
//

import SwiftUI
import CoreData
import AppKit

@main
struct AudiometryApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @ObservedObject private var languageManager = LanguageManager.shared
    @AppStorage("storageMode") private var storageModeRaw: String = StorageMode.coreData.rawValue
    let persistenceController = PersistenceController.shared
    
    var storageMode: StorageMode {
        StorageMode(rawValue: storageModeRaw) ?? .coreData
    }
    
    var body: some Scene {
        WindowGroup {
            VStack(spacing: 0) {
                // Storage Mode Selector
                HStack {
					Text("storage_mode:".localized)
						.foregroundColor(.secondary)
                        .font(.headline)
                    Spacer()
                    Picker("", selection: $storageModeRaw) {
                        ForEach(StorageMode.allCases, id: \.rawValue) { mode in
                            Text(mode.displayName).tag(mode.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 300)
                    
                    Spacer()

					let Text1 = "current: ".localized
					let Text2 = storageMode.displayName
					Text(Text1 + Text2)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .padding()
                .background(Color(NSColor.windowBackgroundColor))
                
                Divider()
                
                // Content based on storage mode
                if storageMode == .coreData {
                    ContentView()
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                } else {
                    ContentViewSwiftUI()
                }
            }
            
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
