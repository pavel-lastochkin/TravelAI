//
//  LocationManager.swift
//  Travel AI
//
//  Created by Pavel Lastochkin on 14.06.2026.
//

import Combine
import CoreLocation
import Foundation

struct LocationCoordinate: Sendable, Equatable {
    let latitude: Double
    let longitude: Double
}

@MainActor
final class LocationManager: NSObject, ObservableObject {
    @Published private(set) var statusMessage = "Location unavailable — analyzing photo only"

    private let manager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocation?, Never>?
    private var authorizationContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        updateStatusMessage(hasCoordinate: false)
    }

    func requestPermissionIfNeeded() {
        guard manager.authorizationStatus == .notDetermined else { return }
        manager.requestWhenInUseAuthorization()
    }

    func currentCoordinateForAnalysis() async -> LocationCoordinate? {
        guard CLLocationManager.locationServicesEnabled() else {
            updateStatusMessage(hasCoordinate: false)
            return nil
        }

        let status = await resolvedAuthorizationStatus()
        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            updateStatusMessage(hasCoordinate: false)
            return nil
        }

        guard let location = await requestSingleLocation() else {
            updateStatusMessage(hasCoordinate: false)
            return nil
        }

        updateStatusMessage(hasCoordinate: true)
        return LocationCoordinate(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
    }

    private func resolvedAuthorizationStatus() async -> CLAuthorizationStatus {
        let status = manager.authorizationStatus
        guard status == .notDetermined else { return status }

        return await withCheckedContinuation { continuation in
            authorizationContinuation = continuation
            manager.requestWhenInUseAuthorization()
        }
    }

    private func requestSingleLocation() async -> CLLocation? {
        await withCheckedContinuation { continuation in
            locationContinuation = continuation
            manager.requestLocation()
        }
    }

    private func updateStatusMessage(hasCoordinate: Bool) {
        statusMessage = hasCoordinate
            ? "Using current location for better recognition"
            : "Location unavailable — analyzing photo only"
    }
}

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            if let authorizationContinuation {
                self.authorizationContinuation = nil
                authorizationContinuation.resume(returning: manager.authorizationStatus)
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            guard let locationContinuation else { return }
            self.locationContinuation = nil
            locationContinuation.resume(returning: locations.last)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            print("Location error: \(error.localizedDescription)")
            guard let locationContinuation else { return }
            self.locationContinuation = nil
            locationContinuation.resume(returning: nil)
        }
    }
}
