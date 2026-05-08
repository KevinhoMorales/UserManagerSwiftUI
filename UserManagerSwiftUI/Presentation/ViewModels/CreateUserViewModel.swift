//
//  CreateUserViewModel.swift
//  UserManagerSwiftUI
//
//  Created by Kevinho Morales on 7/5/26.
//

import Foundation

// MARK: - CreateUserViewModel

struct CreateUserViewModel {

    // MARK: Actions

    func requestCurrentLocation(using locationManager: LocationManager) {
        locationManager.requestCurrentLocation()
    }

    // MARK: Formatting

    func coordinatesAlertBody(latitude: Double, longitude: Double) -> String {
        L10n.CreateUser.coordinatesBody(latitude: latitude, longitude: longitude)
    }
}
