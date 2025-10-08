//
//  StorageMode.swift
//  Audiometry
//
//  Enum to toggle between CoreData and SwiftUI storage
//
//  Created by GitHub Copilot on 20/09/2025.
//  Modified by perez987 on 20/09/2025.
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
