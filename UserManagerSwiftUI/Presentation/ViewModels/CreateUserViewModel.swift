//
//  CreateUserViewModel.swift
//  UserManagerSwiftUI
//
//  Created by Kevinho Morales on 7/5/26.
//

import Foundation

// MARK: - CreateUserViewModel

/// Presentation helpers and location actions for create-user flow (keeps `CreateUserView` thin).
struct CreateUserViewModel {

    // MARK: Actions

    func requestCurrentLocation(using locationManager: LocationManager) {
        locationManager.requestCurrentLocation()
    }

    // MARK: Formatting

    func coordinatesAlertBody(latitude: Double, longitude: Double) -> String {
        String(
            format: "Latitude: %.6f\nLongitude: %.6f",
            latitude,
            longitude
        )
    }
}
