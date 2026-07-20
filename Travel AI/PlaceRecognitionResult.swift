//
//  PlaceRecognitionResult.swift
//  Travel AI
//
//  Created by Pavel Lastochkin on 14.06.2026.
//

import Foundation

struct PlaceRecognitionResult: Decodable {
    let placeName: String
    let city: String
    let country: String
    let confidence: Int
    let quickFacts: [String]
    let story: String
    let followUpQuestions: [String]

    var locationSummary: String {
        [city, country]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }

    private enum CodingKeys: String, CodingKey {
        case placeName
        case city
        case country
        case location
        case confidence
        case quickFacts
        case story
        case followUpQuestions
        case description
        case interestingFact
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        placeName = try container.decode(String.self, forKey: .placeName)
        confidence = try Self.decodeConfidence(from: container)

        if let location = try container.decodeIfPresent(String.self, forKey: .location) {
            let parts = location.split(separator: ",", maxSplits: 1).map {
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            city = parts.first.map { String($0) } ?? location
            country = parts.count > 1 ? String(parts[1]) : ""
        } else {
            city = try container.decodeIfPresent(String.self, forKey: .city) ?? ""
            country = try container.decodeIfPresent(String.self, forKey: .country) ?? ""
        }

        if let quickFacts = try container.decodeIfPresent([String].self, forKey: .quickFacts), !quickFacts.isEmpty {
            self.quickFacts = quickFacts
        } else if let interestingFact = try container.decodeIfPresent(String.self, forKey: .interestingFact), !interestingFact.isEmpty {
            self.quickFacts = [interestingFact]
        } else {
            self.quickFacts = []
        }

        if let story = try container.decodeIfPresent(String.self, forKey: .story), !story.isEmpty {
            self.story = story
        } else if let description = try container.decodeIfPresent(String.self, forKey: .description), !description.isEmpty {
            self.story = description
        } else {
            self.story = ""
        }

        followUpQuestions = try container.decodeIfPresent([String].self, forKey: .followUpQuestions) ?? []
    }

    init(
        placeName: String,
        city: String,
        country: String,
        confidence: Int,
        quickFacts: [String],
        story: String,
        followUpQuestions: [String]
    ) {
        self.placeName = placeName
        self.city = city
        self.country = country
        self.confidence = confidence
        self.quickFacts = quickFacts
        self.story = story
        self.followUpQuestions = followUpQuestions
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
