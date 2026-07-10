//
//  LocationManager.swift
//  Travel AI
//
//  Created by Pavel Lastochkin on 14.06.2026.
//

import Combine
import CoreLocation
import Foundation

@MainActor
final class LocationManager: NSObject, ObservableObject {
    private let manager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocation?, Never>?
    private var authorizationContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestPermissionIfNeeded() {
        guard manager.authorizationStatus == .notDetermined else { return }
        manager.requestWhenInUseAuthorization()
    }

    func cameraCaptureContext() async -> PhotoLocationContext? {
        guard CLLocationManager.locationServicesEnabled() else { return nil }

        let status = await resolvedAuthorizationStatus()
        guard status == .authorizedWhenInUse || status == .authorizedAlways else { return nil }

        guard let location = await requestSingleLocation() else { return nil }

        return PhotoLocationContext(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            source: .cameraCapture
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
