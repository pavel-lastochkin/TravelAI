//
//  GeminiService.swift
//  Travel AI
//
//  Created by Pavel Lastochkin on 14.06.2026.
//

import Foundation
import UIKit

enum GeminiServiceError: LocalizedError {
    case missingAPIKey
    case invalidURL
    case invalidImage
    case invalidResponse
    case apiError
    case emptyResponse
    case jsonParsingFailed(rawResponse: String)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Add your Gemini API key to Secrets.xcconfig, then clean build (Product → Clean Build Folder)."
        case .invalidURL:
            return "Invalid API URL."
        case .invalidImage:
            return "Could not process the selected image."
        case .invalidResponse:
            return "Invalid server response."
        case .apiError:
            return "Something went wrong while analyzing the photo. Please try again."
        case .emptyResponse:
            return "No response from AI."
        case .jsonParsingFailed:
            return "Could not read the AI response. Please try again."
        }
    }
}

func askGemini(place: String) async -> String {
    let prompt = "Tell me briefly about \(place) as a travel destination."
    do {
        return try await generateContent(parts: [["text": prompt]])
    } catch {
        return "Error: \(error.localizedDescription)"
    }
}

func analyzePlace(
    image: UIImage,
    location: PhotoLocationContext? = nil,
    responseLanguage: String
) async throws -> PlaceRecognitionResult {
    guard let jpegData = image.jpegData(compressionQuality: 0.8) else {
        throw GeminiServiceError.invalidImage
    }

    let prompt = PromptBuilder.analyzePlacePrompt(
        location: location,
        responseLanguage: responseLanguage
    )

    return try await decodeGeminiJSON(
        parts: [
            ["text": prompt],
            [
                "inline_data": [
                    "mime_type": "image/jpeg",
                    "data": jpegData.base64EncodedString(),
                ],
            ],
        ]
    )
}

func fetchPlaceDetails(
    place: PlaceRecognitionResult,
    responseLanguage: String
) async throws -> PlaceDetailContent {
    let prompt = PromptBuilder.placeDetailsPrompt(
        place: place,
        responseLanguage: responseLanguage
    )
    return try await decodeGeminiJSON(parts: [["text": prompt]])
}

func fetchNearbyPlaces(
    place: PlaceRecognitionResult,
    location: PhotoLocationContext?,
    responseLanguage: String
) async throws -> NearbyPlacesResult {
    let prompt = PromptBuilder.nearbyPlacesPrompt(
        place: place,
        location: location,
        responseLanguage: responseLanguage
    )
    return try await decodeGeminiJSON(parts: [["text": prompt]])
}

private func decodeGeminiJSON<T: Decodable>(parts: [[String: Any]]) async throws -> T {
    let rawResponse = try await generateContent(parts: parts)
    let jsonString = sanitizeJSONResponse(rawResponse)

    do {
        guard let data = jsonString.data(using: .utf8) else {
            throw GeminiServiceError.jsonParsingFailed(rawResponse: rawResponse)
        }
        let decoded = try JSONDecoder().decode(T.self, from: data)
        #if DEBUG
        print("Gemini decoded \(String(describing: T.self)):\n\(jsonString)")
        #endif
        return decoded
    } catch {
        print("Gemini JSON parsing failed. Raw response:\n\(rawResponse)")
        throw GeminiServiceError.jsonParsingFailed(rawResponse: rawResponse)
    }
}

private func sanitizeJSONResponse(_ text: String) -> String {
    var cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)

    if cleaned.hasPrefix("```") {
        cleaned = cleaned
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    if let start = cleaned.firstIndex(of: "{"),
       let end = cleaned.lastIndex(of: "}") {
        cleaned = String(cleaned[start...end])
    }

    return cleaned
}

private func generateContent(parts: [[String: Any]]) async throws -> String {
    let apiKey = Configuration.geminiAPIKey
    guard !apiKey.isEmpty else {
        throw GeminiServiceError.missingAPIKey
    }

    guard let url = URL(string: "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent") else {
        throw GeminiServiceError.invalidURL
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

    request.httpBody = try JSONSerialization.data(withJSONObject: body)
    let (data, urlResponse) = try await URLSession.shared.data(for: request)

    guard let httpResponse = urlResponse as? HTTPURLResponse else {
        throw GeminiServiceError.invalidResponse
    }

    if httpResponse.statusCode != 200 {
        if let apiError = try? JSONDecoder().decode(GeminiErrorResponse.self, from: data) {
            print("Gemini API error: \(apiError.error.message)")
        } else if let body = String(data: data, encoding: .utf8) {
            print("Gemini API error (HTTP \(httpResponse.statusCode)): \(body)")
        }
        throw GeminiServiceError.apiError
    }

    let decoded = try JSONDecoder().decode(GeminiResponse.self, from: data)
    guard let text = decoded.candidates.first?.content.parts.first?.text, !text.isEmpty else {
        throw GeminiServiceError.emptyResponse
    }
    return text
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
