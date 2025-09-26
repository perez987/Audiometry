//
//  LanguageManager.swift
//  Audiometry
//
//  Created by GitHub Copilot on 2025/01/10.
//

import Foundation
import SwiftUI

class LanguageManager: ObservableObject {
    @Published var currentLanguage: Language = .english
    
    enum Language: String, CaseIterable {
        case english = "en"
        case spanish = "es"
        
        var displayName: String {
            switch self {
            case .english: return "English"
            case .spanish: return "Español"
            }
        }
    }
    
    static let shared = LanguageManager()
    
    private init() {
        // Load saved language preference
        if let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage"),
           let language = Language(rawValue: savedLanguage) {
            currentLanguage = language
        }
    }
    
    func setLanguage(_ language: Language) {
        currentLanguage = language
        UserDefaults.standard.set(language.rawValue, forKey: "selectedLanguage")
    }
    
    func localizedString(for key: String) -> String {
        return NSLocalizedString(key, bundle: Bundle.main, comment: "")
    }
}

// Extension for convenient localization
extension String {
    var localized: String {
        return NSLocalizedString(self, bundle: Bundle.main, comment: "")
    }
    
    func localized(with arguments: CVarArg...) -> String {
        return String(format: NSLocalizedString(self, bundle: Bundle.main, comment: ""), arguments: arguments)
    }
}