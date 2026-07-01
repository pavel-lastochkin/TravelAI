//
//  Configuration.swift
//  Travel AI
//
//  Created by Pavel Lastochkin on 14.06.2026.
//

import Foundation

enum Configuration {
    static var geminiAPIKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String,
              !key.isEmpty else {
            print("Configuration: GEMINI_API_KEY is missing or empty. Add your key to Secrets.xcconfig and clean build.")
            return ""
        }
        return key
    }
}
