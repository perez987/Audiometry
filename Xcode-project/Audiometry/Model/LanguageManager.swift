//
//   LanguageManager.swift
//  Audiometry
//
//  Modified by perez987 on 20/09/2025.
//
//  FIXED: Dynamic language switching at runtime
//  - Loads appropriate language bundle (en.lproj/es.lproj) based on user selection
//  - Updates all UI elements when language changes through @Published property
//

import Foundation
import SwiftUI

@MainActor
class LanguageManager: ObservableObject {
    @Published var currentLanguage: Language = .english
    private var currentBundle: Bundle = .main

    enum Language: String, CaseIterable {
        case english = "en"
        case spanish = "es"
        case french = "fr"
        case italian = "it"

        var displayName: String {
            switch self {
            case .english: "🇬🇧 English"
            case .spanish: "🇪🇸 Español"
            case .french: "🇫🇷 Français"
            case .italian: "🇮🇹 Italiano"
            }
        }
    }

    static let shared = LanguageManager()

    private init() {
        // Load saved language preference
        if let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage"),
           let language = Language(rawValue: savedLanguage)
        {
            currentLanguage = language
        }
        updateBundle()
    }

    func setLanguage(_ language: Language) {
        // Avoid unnecessary changes
        guard currentLanguage != language else { return }

        currentLanguage = language
        UserDefaults.standard.set(language.rawValue, forKey: "selectedLanguage")
        updateBundle()
    }

    private func updateBundle() {
        guard let path = Bundle.main.path(forResource: currentLanguage.rawValue, ofType: "lproj") else {
            // Fallback to main bundle if language bundle not found
            currentBundle = Bundle.main
            return
        }

        guard let bundle = Bundle(path: path) else {
            // Fallback to main bundle if bundle creation fails
            currentBundle = Bundle.main
            return
        }

        currentBundle = bundle
    }

    func localizedString(for key: String) -> String {
        NSLocalizedString(key, bundle: currentBundle, comment: "")
    }
}

/// Extension for convenient localization
extension String {
    @MainActor
    var localized: String {
        LanguageManager.shared.localizedString(for: self)
    }

    @MainActor
    func localized(with arguments: CVarArg...) -> String {
        String(format: LanguageManager.shared.localizedString(for: self), arguments: arguments)
    }
}
