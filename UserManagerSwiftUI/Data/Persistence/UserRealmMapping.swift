//
//  UserRealmMapping.swift
//  UserManagerSwiftUI
//
//  Created by Kevinho Morales on 7/5/26.
//

import Foundation
import RealmSwift

// MARK: - RealmUserObject + Domain Mapping

extension RealmUserObject {

    /// Applies domain values suitable before `realm.add(..., update: .modified)`.
    func apply(domain user: User) {
        id = user.id
        username = user.username
        name = user.name
        email = user.email
        phone = user.phone
        city = user.city
        latitude = user.latitude
        longitude = user.longitude
    }

    convenience init(domain user: User) {
        self.init()
        apply(domain: user)
    }
}

// MARK: - User + Realm Mapping

extension User {

    init(realmObject: RealmUserObject) {
        id = realmObject.id
        username = realmObject.username
        name = realmObject.name
        email = realmObject.email
        phone = realmObject.phone
        city = realmObject.city
        latitude = realmObject.latitude
        longitude = realmObject.longitude
    }
}
