//
//  StorageMode.swift
//  Audiometry
//
//  Enum to toggle between CoreData and SwiftUI storage
//

import Foundation

enum StorageMode: String, CaseIterable {
    case coreData = "CoreData"
    case swiftUI = "SwiftUI"
    
    var displayName: String {
        switch self {
        case .coreData:
            return "CoreData Storage"
        case .swiftUI:
            return "SwiftUI Storage"
        }
    }
}
