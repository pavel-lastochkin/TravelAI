//
//  PlaceContinuationModels.swift
//  Travel AI
//
//  Created by Pavel Lastochkin on 20.07.2026.
//

import Foundation

enum PlaceExploreAction: String, CaseIterable, Identifiable {
    case history
    case visit
    case nearby

    var id: String { rawValue }

    var title: String {
        switch self {
        case .history:
            return "Learn the history"
        case .visit:
            return "How to visit"
        case .nearby:
            return "See nearby"
        }
    }

    var systemImage: String {
        switch self {
        case .history:
            return "book"
        case .visit:
            return "ticket"
        case .nearby:
            return "mappin.and.ellipse"
        }
    }
}

struct PlaceDetailContent: Decodable, Equatable {
    let history: String
    let visitInfo: String
}

struct NearbyPlaceItem: Decodable, Equatable, Identifiable {
    let name: String
    let distanceHint: String
    let whyVisit: String

    var id: String { name }
}

struct NearbyPlacesResult: Decodable, Equatable {
    let places: [NearbyPlaceItem]
}
