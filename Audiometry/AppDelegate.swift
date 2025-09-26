//
//  AppDelegate.swift
//
//  Created by Emilio P Egido on 2025-08-23
//

import AppKit
import Foundation

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_: Notification) {

    }
        
//    func viewDidLoad() {
//    }

    // Close app from red button (thanks Chris1111)
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        return true
    }
    
//    func applicationWillTerminate(_ aNotification: Notification) {
//
//    }
    
}
