// Copyright 2025 Bobby529
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//     http://www.apache.org/licenses/LICENSE-2.0

import Foundation
import CoreLocation
import Combine

final class LocationManager: NSObject, ObservableObject {
    enum AuthState: String {
        case notDetermined, restricted, denied, authorised
    }

    @Published private(set) var authorisation: AuthState = .notDetermined
    @Published private(set) var lastLocation: CLLocation?
    @Published private(set) var errorText: String?

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        // On macOS, “when in use” is the normal flow
        manager.requestWhenInUseAuthorization()
    }

    func start() {
        clearError()
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            self.authorisation = mapAuth(manager.authorizationStatus)
            self.errorText = "Location access is \(authorisation.rawValue). Open System Settings → Privacy & Security → Location Services."
        case .authorized, .authorizedWhenInUse, .authorizedAlways:
            self.authorisation = .authorised
            manager.startUpdatingLocation()
        @unknown default:
            self.errorText = "Unknown authorisation state."
        }
    }

    func stop() {
        manager.stopUpdatingLocation()
    }

    private func mapAuth(_ status: CLAuthorizationStatus) -> AuthState {
        switch status {
        case .notDetermined: return .notDetermined
        case .restricted:    return .restricted
        case .denied:        return .denied
        case .authorized, .authorizedAlways, .authorizedWhenInUse: return .authorised
        @unknown default:    return .notDetermined
        }
    }

    private func clearError() { self.errorText = nil }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.authorisation = mapAuth(manager.authorizationStatus)
        if authorisation == .authorised {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.errorText = error.localizedDescription
    }
}
