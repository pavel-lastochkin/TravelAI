//
//  AppSettings.swift
//  Travel AI
//
//  Created by Pavel Lastochkin on 14.06.2026.
//

import Combine
import SwiftUI

@MainActor
final class AppSettings: ObservableObject {
    private enum StorageKey {
        static let aiResponseLanguage = "aiResponseLanguage"
        static let appLanguage = "appLanguage"
    }

    @AppStorage(StorageKey.aiResponseLanguage)
    private var aiResponseLanguageRaw = AIResponseLanguage.sameAsSystem.rawValue

    @AppStorage(StorageKey.appLanguage)
    private var appLanguageRaw = AIResponseLanguage.sameAsSystem.rawValue

    var aiResponseLanguage: AIResponseLanguage {
        get { AIResponseLanguage(rawValue: aiResponseLanguageRaw) ?? .sameAsSystem }
        set { aiResponseLanguageRaw = newValue.rawValue }
    }

    var appLanguage: AIResponseLanguage {
        get { AIResponseLanguage(rawValue: appLanguageRaw) ?? .sameAsSystem }
        set { appLanguageRaw = newValue.rawValue }
    }

    var aiResponseLanguageBinding: Binding<AIResponseLanguage> {
        Binding(
            get: { self.aiResponseLanguage },
            set: { self.aiResponseLanguage = $0 }
        )
    }

    var resolvedAIResponseLanguageName: String {
        aiResponseLanguage.resolvedPromptLanguageName()
    }
}
