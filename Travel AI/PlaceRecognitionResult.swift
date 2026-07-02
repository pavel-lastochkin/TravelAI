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
}
