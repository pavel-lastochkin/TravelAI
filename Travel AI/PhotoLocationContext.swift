//
//  PhotoLocationContext.swift
//  Travel AI
//
//  Created by Pavel Lastochkin on 14.06.2026.
//

import CoreLocation
import Foundation
import MapKit

enum PhotoSource: Sendable, Equatable {
    case camera
    case gallery
}

struct PhotoLocationContext: Sendable, Equatable {
    enum Source: Sendable {
        case photoMetadata
        case cameraCapture
    }

    let latitude: Double
    let longitude: Double
    let source: Source

    var sourceLabel: String {
        switch source {
        case .photoMetadata:
            return "Photo location"
        case .cameraCapture:
            return "Camera location"
        }
    }

    var coordinateSummary: String {
        String(format: "%.4f, %.4f", latitude, longitude)
    }

    @MainActor
    func openInMaps() {
        let placemark = MKPlacemark(
            coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        )
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = sourceLabel
        mapItem.openInMaps()
    }
}
