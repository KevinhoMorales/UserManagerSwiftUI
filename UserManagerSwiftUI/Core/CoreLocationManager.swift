//
//  CoreLocationManager.swift
//  UserManagerSwiftUI
//
//  Created by Kevinho Morales on 7/5/26.
//

import CoreLocation
import Foundation
import Observation

// MARK: - Location User Messages

private let locationDeniedUserMessage =
    "Location access is turned off. You can enable it in Settings → Privacy & Security → Location Services for this app."
private let locationUnsupportedUserMessage = "Location is not available for this app in its current configuration."
private let locationNoSampleUserMessage = "No location sample was returned."
private let locationTransientFailureUserMessage = "Could not determine your position yet. Try again in a few seconds."

// MARK: - CoreLocationManager

@MainActor
@Observable
final class CoreLocationManager: NSObject, LocationManager {

    // MARK: Published State

    private(set) var latitude: Double?
    private(set) var longitude: Double?
    private(set) var authorizationStatus: CLAuthorizationStatus
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    // MARK: Private

    private let manager: CLLocationManager
    private var isRequestInFlight = false
    private var shouldFetchAfterAuthorization = false

    // MARK: Lifecycle

    override init() {
        let manager = CLLocationManager()
        self.manager = manager
        self.authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    // MARK: LocationManager

    func requestWhenInUseAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    func requestCurrentLocation() {
        guard isRequestInFlight == false else { return }

        errorMessage = nil
        authorizationStatus = manager.authorizationStatus

        switch authorizationStatus {
        case .notDetermined:
            shouldFetchAfterAuthorization = true
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            beginLocationRequestIfPossible()
        case .denied, .restricted:
            errorMessage = locationDeniedUserMessage
        @unknown default:
            errorMessage = locationUnsupportedUserMessage
        }
    }

    // MARK: Private Helpers

    private func beginLocationRequestIfPossible() {
        guard isRequestInFlight == false else { return }
        shouldFetchAfterAuthorization = false
        isRequestInFlight = true
        isLoading = true
        latitude = nil
        longitude = nil
        errorMessage = nil
        manager.requestLocation()
    }

    private func finishRequest() {
        isRequestInFlight = false
        isLoading = false
    }
}

// MARK: - Error Mapping

private nonisolated func userFacingErrorMessage(from error: Error) -> String {
    guard let error = error as? CLError else {
        return error.localizedDescription
    }
    switch error.code {
    case .denied, .promptDeclined:
        return locationDeniedUserMessage
    case .locationUnknown, .network:
        return locationTransientFailureUserMessage
    default:
        return error.localizedDescription
    }
}

// MARK: - CLLocationManagerDelegate

extension CoreLocationManager: CLLocationManagerDelegate {

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            authorizationStatus = status
            if shouldFetchAfterAuthorization,
               status == .authorizedAlways || status == .authorizedWhenInUse {
                beginLocationRequestIfPossible()
            } else if shouldFetchAfterAuthorization,
                      status == .denied || status == .restricted {
                shouldFetchAfterAuthorization = false
                errorMessage = locationDeniedUserMessage
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            Task { @MainActor in
                errorMessage = locationNoSampleUserMessage
                finishRequest()
            }
            return
        }

        Task { @MainActor in
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            errorMessage = nil
            finishRequest()
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            latitude = nil
            longitude = nil
            errorMessage = userFacingErrorMessage(from: error)
            finishRequest()
        }
    }
}
