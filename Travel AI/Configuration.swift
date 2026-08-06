//
//  Configuration.swift
//  Travel AI
//
//  Created by Pavel Lastochkin on 14.06.2026.
//

import Foundation

enum Configuration {
    /// Backend API base URL without trailing slash.
    /// Priority:
    /// 1. `BACKEND_BASE_URL` from Secrets.xcconfig / Info.plist
    /// 2. Simulator localhost fallback
    static var backendBaseURL: String {
        if let configured = Bundle.main.object(forInfoDictionaryKey: "BACKEND_BASE_URL") as? String {
            let trimmed = configured
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            if !trimmed.isEmpty,
               !trimmed.hasPrefix("$("),
               trimmed != "YOUR_BACKEND_BASE_URL_HERE" {
                return trimmed
            }
        }

        #if targetEnvironment(simulator)
        return "http://127.0.0.1:8000"
        #else
        return "http://127.0.0.1:8000"
        #endif
    }

    static var geminiAPIKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String,
              !key.isEmpty else {
            print("Configuration: GEMINI_API_KEY is missing or empty. Add your key to Secrets.xcconfig and clean build.")
            return ""
        }
        return key
    }
}
