//
//  LocationManager.swift
//  UserManagerSwiftUI
//
//  Created by Kevinho Morales on 7/5/26.
//

import CoreLocation
import Foundation

// MARK: - LocationManager

@MainActor
protocol LocationManager: AnyObject {

    var latitude: Double? { get }
    var longitude: Double? { get }
    var authorizationStatus: CLAuthorizationStatus { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }

    func requestWhenInUseAuthorization()
    func requestCurrentLocation()
}
