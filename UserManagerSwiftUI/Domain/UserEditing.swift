//
//  UserEditing.swift
//  UserManagerSwiftUI
//
//  Created by Kevinho Morales on 7/5/26.
//

import Foundation

// MARK: - User (Editing)

extension User {

    /// Returns a copy with selective field overrides (used after local edits).
    func updating(name: String? = nil, email: String? = nil) -> User {
        User(
            id: id,
            username: username,
            name: name ?? self.name,
            email: email ?? self.email,
            phone: phone,
            city: city,
            latitude: latitude,
            longitude: longitude
        )
    }
}
