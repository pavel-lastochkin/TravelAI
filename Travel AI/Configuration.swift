//
//  Configuration.swift
//  Travel AI
//
//  Created by Pavel Lastochkin on 14.06.2026.
//

import Foundation

enum Configuration {
    /// Backend API base URL without trailing slash.
    ///
    /// Prefer `BACKEND_HOST` in Secrets.xcconfig (host only, no https://).
    /// That avoids xcconfig treating `//` as a comment and breaking TLS URLs.
    static var backendBaseURL: String {
        if let host = Bundle.main.object(forInfoDictionaryKey: "BACKEND_HOST") as? String {
            let cleaned = host
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            if !cleaned.isEmpty,
               !cleaned.hasPrefix("$("),
               cleaned != "YOUR_BACKEND_HOST_HERE" {
                let url = "https://\(cleaned)"
                #if DEBUG
                print("Configuration.backendBaseURL → \(url)")
                #endif
                return url
            }
        }

        // Legacy fallback if an old full URL key is still present.
        if let configured = Bundle.main.object(forInfoDictionaryKey: "BACKEND_BASE_URL") as? String {
            var trimmed = configured.trimmingCharacters(in: .whitespacesAndNewlines)
            while trimmed.hasSuffix("/") {
                trimmed.removeLast()
            }
            if trimmed.hasPrefix("https://") || trimmed.hasPrefix("http://"),
               !trimmed.contains("$(") {
                #if DEBUG
                print("Configuration.backendBaseURL (legacy) → \(trimmed)")
                #endif
                return trimmed
            }
        }

        let localhost = "http://127.0.0.1:8000"
        #if DEBUG
        print("Configuration.backendBaseURL → \(localhost) (localhost fallback)")
        #endif
        return localhost
    }
}
