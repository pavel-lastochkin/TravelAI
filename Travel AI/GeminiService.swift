//
//  GeminiService.swift
//  Travel AI
//
//  Created by Pavel Lastochkin on 14.06.2026.
//

import Foundation
import UIKit

func askGemini(place: String) async -> String {
    let prompt = "Tell me briefly about \(place) as a travel destination."
    return await generateContent(parts: [["text": prompt]])
}

func analyzePlace(image: UIImage) async -> String {
    guard let jpegData = image.jpegData(compressionQuality: 0.8) else {
        return "Error: Could not process image."
    }

    let prompt = "Identify this place. If it's a landmark, return its name and a short description for tourists."
    return await generateContent(parts: [
        ["text": prompt],
        [
            "inline_data": [
                "mime_type": "image/jpeg",
                "data": jpegData.base64EncodedString(),
            ],
        ],
    ])
}

private func generateContent(parts: [[String: Any]]) async -> String {
    let apiKey = Configuration.geminiAPIKey
    guard !apiKey.isEmpty else {
        return "Error: Add your Gemini API key to Secrets.xcconfig, then clean build (Product → Clean Build Folder)."
    }

    guard let url = URL(string: "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent") else {
        return "Error: Invalid API URL."
    }

    let body: [String: Any] = [
        "contents": [
            ["parts": parts],
        ],
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
