//
//  AIResponseLanguage.swift
//  Travel AI
//
//  Created by Pavel Lastochkin on 14.06.2026.
//

import Foundation

enum AIResponseLanguage: String, CaseIterable, Identifiable {
    case sameAsSystem
    case english
    case russian

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .sameAsSystem:
            return "Same as System"
        case .english:
            return "English"
        case .russian:
            return "Russian"
        }
    }

    func resolvedPromptLanguageName() -> String {
        switch self {
        case .sameAsSystem:
            return Self.promptLanguageName(for: Locale.current)
        case .english:
            return "English"
        case .russian:
            return "Russian"
        }
    }

    private static func promptLanguageName(for locale: Locale) -> String {
        let languageCode = locale.language.languageCode?.identifier
            ?? Locale.preferredLanguages.first?
                .split(separator: "-")
                .first
                .map(String.init)

        switch languageCode {
        case "ru":
            return "Russian"
        default:
            return "English"
        }
    }
}
