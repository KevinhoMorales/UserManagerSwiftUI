//
//  UserDTO.swift
//  UserManagerSwiftUI
//
//  Created by Kevinho Morales on 7/5/26.
//

import Foundation

// MARK: - UserDTO

struct UserDTO: Decodable, Sendable {

    // MARK: Nested Types

    struct AddressDTO: Decodable, Sendable {
        let street: String
        let suite: String
        let city: String
        let zipcode: String
        let geo: GeoDTO
    }

    struct GeoDTO: Decodable, Sendable {
        let lat: String
        let lng: String
    }

    // MARK: Properties

    let id: Int
    let name: String
    let username: String
    let email: String
    let phone: String
    let address: AddressDTO
}

// MARK: - Mapping

extension UserDTO {

    func toDomain() -> User {
        let latitude = Double(address.geo.lat) ?? 0
        let longitude = Double(address.geo.lng) ?? 0

        return User(
            id: id,
            username: username,
            name: name,
            email: email,
            phone: phone,
            city: address.city,
            latitude: latitude,
            longitude: longitude
        )
    }
}
