//
//  BackendAPIClient.swift
//  Travel AI
//
//  Created by Pavel Lastochkin on 06.08.2026.
//

import Foundation
import UIKit

enum BackendAPIError: LocalizedError {
    case invalidURL
    case invalidImage
    case invalidResponse
    case serverError(statusCode: Int, message: String)
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid backend URL. Check Configuration.backendBaseURL."
        case .invalidImage:
            return "Could not process the selected image."
        case .invalidResponse:
            return "Invalid server response."
        case .serverError(_, let message):
            return message
        case .decodingFailed:
            return "Could not read the backend response. Please try again."
        }
    }
}

enum BackendAPIClient {
    static func analyzePlace(
        image: UIImage,
        location: PhotoLocationContext? = nil,
        responseLanguage: String
    ) async throws -> PlaceRecognitionResult {
        guard let jpegData = image.jpegData(compressionQuality: 0.8) else {
            throw BackendAPIError.invalidImage
        }

        let url = try endpoint("/v1/places/analyze")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 60

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        appendFormField(name: "language", value: responseLanguage, boundary: boundary, to: &body)

        if let location {
            appendFormField(name: "latitude", value: String(location.latitude), boundary: boundary, to: &body)
            appendFormField(name: "longitude", value: String(location.longitude), boundary: boundary, to: &body)
            appendFormField(
                name: "location_source",
                value: locationSourceValue(location.source),
                boundary: boundary,
                to: &body
            )
        }

        appendFileField(
            name: "image",
            filename: "photo.jpg",
            mimeType: "image/jpeg",
            fileData: jpegData,
            boundary: boundary,
            to: &body
        )

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        #if DEBUG
        print("Backend analyze → \(url.absoluteString)")
        #endif

        return try await send(request)
    }

    static func fetchPlaceDetails(
        place: PlaceRecognitionResult,
        location: PhotoLocationContext? = nil,
        responseLanguage: String
    ) async throws -> PlaceDetailContent {
        let payload = PlaceContextRequest(
            placeName: place.placeName,
            city: place.city,
            country: place.country,
            quickFacts: place.quickFacts,
            story: place.story,
            language: responseLanguage,
            latitude: location?.latitude,
            longitude: location?.longitude
        )
        return try await postJSON(path: "/v1/places/details", payload: payload)
    }

    static func fetchNearbyPlaces(
        place: PlaceRecognitionResult,
        location: PhotoLocationContext?,
        responseLanguage: String
    ) async throws -> NearbyPlacesResult {
        let payload = PlaceContextRequest(
            placeName: place.placeName,
            city: place.city,
            country: place.country,
            quickFacts: place.quickFacts,
            story: place.story,
            language: responseLanguage,
            latitude: location?.latitude,
            longitude: location?.longitude
        )
        return try await postJSON(path: "/v1/places/nearby", payload: payload)
    }

    private static func postJSON<Body: Encodable, Response: Decodable>(
        path: String,
        payload: Body
    ) async throws -> Response {
        let url = try endpoint(path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)

        #if DEBUG
        print("Backend \(path) → \(url.absoluteString)")
        #endif

        return try await send(request)
    }

    private static func send<Response: Decodable>(_ request: URLRequest) async throws -> Response {
        let (data, urlResponse) = try await URLSession.shared.data(for: request)

        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            throw BackendAPIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let message = serverErrorMessage(from: data) ?? "Backend error (\(httpResponse.statusCode))."
            #if DEBUG
            if let body = String(data: data, encoding: .utf8) {
                print("Backend error \(httpResponse.statusCode): \(body)")
            }
            #endif
            throw BackendAPIError.serverError(statusCode: httpResponse.statusCode, message: message)
        }

        do {
            let decoded = try JSONDecoder().decode(Response.self, from: data)
            #if DEBUG
            if let body = String(data: data, encoding: .utf8) {
                print("Backend decoded \(String(describing: Response.self)):\n\(body)")
            }
            #endif
            return decoded
        } catch {
            #if DEBUG
            if let body = String(data: data, encoding: .utf8) {
                print("Backend decoding failed. Raw response:\n\(body)")
            }
            #endif
            throw BackendAPIError.decodingFailed
        }
    }

    private static func endpoint(_ path: String) throws -> URL {
        let base = Configuration.backendBaseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let url = URL(string: base + path) else {
            throw BackendAPIError.invalidURL
        }
        return url
    }

    private static func locationSourceValue(_ source: PhotoLocationContext.Source) -> String {
        switch source {
        case .photoMetadata:
            return "photoMetadata"
        case .cameraCapture:
            return "cameraCapture"
        }
    }

    private static func appendFormField(
        name: String,
        value: String,
        boundary: String,
        to data: inout Data
    ) {
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(value)\r\n".data(using: .utf8)!)
    }

    private static func appendFileField(
        name: String,
        filename: String,
        mimeType: String,
        fileData: Data,
        boundary: String,
        to data: inout Data
    ) {
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append(
            "Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n"
                .data(using: .utf8)!
        )
        data.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        data.append(fileData)
        data.append("\r\n".data(using: .utf8)!)
    }

    private static func serverErrorMessage(from data: Data) -> String? {
        struct DetailError: Decodable {
            let detail: String
        }

        if let error = try? JSONDecoder().decode(DetailError.self, from: data), !error.detail.isEmpty {
            return error.detail
        }
        return String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .nilIfEmpty
    }
}

private struct PlaceContextRequest: Encodable {
    let placeName: String
    let city: String
    let country: String
    let quickFacts: [String]
    let story: String
    let language: String
    let latitude: Double?
    let longitude: Double?
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
