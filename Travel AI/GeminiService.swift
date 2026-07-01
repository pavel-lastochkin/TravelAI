//
//  GeminiService.swift
//  Travel AI
//
//  Created by Pavel Lastochkin on 14.06.2026.
//

import Foundation

func askGemini(place: String) async -> String {
    guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String,
          !apiKey.isEmpty,
          apiKey != "YOUR_GEMINI_API_KEY_HERE",
          !apiKey.hasPrefix("$(") else {
        return "Error: Add your Gemini API key to Secrets.xcconfig, then clean build (Product → Clean Build Folder)."
    }

   // guard apiKey.hasPrefix("AIza") else {
   //     return "Error: Invalid API key format. Create a key at aistudio.google.com/apikey — it should start with \"AIza\"."
   // }

    guard let url = URL(string: "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent") else {
        return "Error: Invalid API URL."
    }

    let prompt = "Tell me briefly about \(place) as a travel destination."
    let body: [String: Any] = [
        "contents": [
            ["parts": [["text": prompt]]]
        ]
    ]

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue(apiKey, forHTTPHeaderField: "x-goog-api-key")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, urlResponse) = try await URLSession.shared.data(for: request)

        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            return "Error: Invalid server response."
        }

        if httpResponse.statusCode != 200 {
            if let apiError = try? JSONDecoder().decode(GeminiErrorResponse.self, from: data) {
                return "Error: \(apiError.error.message)"
            }
            let body = String(data: data, encoding: .utf8) ?? "Unknown error"
            return "Error (\(httpResponse.statusCode)): \(body)"
        }

        let decoded = try JSONDecoder().decode(GeminiResponse.self, from: data)
        guard let text = decoded.candidates.first?.content.parts.first?.text, !text.isEmpty else {
            return "Error: No response from AI."
        }
        return text
    } catch {
        return "Error: \(error.localizedDescription)"
    }
}

private struct GeminiResponse: Decodable {
    let candidates: [Candidate]

    struct Candidate: Decodable {
        let content: Content
    }

    struct Content: Decodable {
        let parts: [Part]
    }

    struct Part: Decodable {
        let text: String
    }
}

private struct GeminiErrorResponse: Decodable {
    let error: APIError

    struct APIError: Decodable {
        let message: String
    }
}
