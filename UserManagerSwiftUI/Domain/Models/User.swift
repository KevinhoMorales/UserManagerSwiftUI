//
//  User.swift
//  UserManagerSwiftUI
//
//  Created by Kevinho Morales on 7/5/26.
//

import Foundation

// MARK: - User

struct User: Identifiable, Equatable, Hashable, Sendable {

    // MARK: Properties

    let id: Int
    let username: String
    let name: String
    let email: String
    let phone: String
    let city: String
    let latitude: Double
    let longitude: Double
}
