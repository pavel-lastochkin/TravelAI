//
//  PlaceRecognitionResult.swift
//  Travel AI
//
//  Created by Pavel Lastochkin on 14.06.2026.
//

import Foundation

struct PlaceRecognitionResult: Codable {
    let placeName: String
    let city: String
    let country: String
    let confidence: Int
    let description: String
    let interestingFact: String

    private enum CodingKeys: String, CodingKey {
        case placeName, city, country, confidence, description, interestingFact
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        placeName = try container.decode(String.self, forKey: .placeName)
        city = try container.decode(String.self, forKey: .city)
        country = try container.decode(String.self, forKey: .country)
        description = try container.decode(String.self, forKey: .description)
        interestingFact = try container.decode(String.self, forKey: .interestingFact)
        confidence = try Self.decodeConfidence(from: container)
    }

    init(
        placeName: String,
        city: String,
        country: String,
        confidence: Int,
        description: String,
        interestingFact: String
    ) {
        self.placeName = placeName
        self.city = city
        self.country = country
        self.confidence = confidence
        self.description = description
        self.interestingFact = interestingFact
    }

    private static func decodeConfidence(from container: KeyedDecodingContainer<CodingKeys>) throws -> Int {
        if let value = try? container.decode(Int.self, forKey: .confidence) {
            return min(max(value, 0), 100)
        }
        if let value = try? container.decode(Double.self, forKey: .confidence) {
            return min(max(Int(value.rounded()), 0), 100)
        }
        if let value = try? container.decode(String.self, forKey: .confidence),
           let parsed = Int(value.trimmingCharacters(in: .whitespacesAndNewlines)) {
            return min(max(parsed, 0), 100)
        }
        throw DecodingError.dataCorruptedError(
            forKey: .confidence,
            in: container,
            debugDescription: "Expected confidence as an integer from 0 to 100."
        )
    }
}
