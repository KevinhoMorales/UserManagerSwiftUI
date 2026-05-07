//
//  RealmUserObject.swift
//  UserManagerSwiftUI
//
//  Created by Kevinho Morales on 7/5/26.
//

import Foundation
import RealmSwift

// MARK: - RealmUserObject

final class RealmUserObject: Object {

    // MARK: Properties

    @Persisted(primaryKey: true) var id: Int
    @Persisted var username: String
    @Persisted var name: String
    @Persisted var email: String
    @Persisted var phone: String
    @Persisted var city: String
    @Persisted var latitude: Double
    @Persisted var longitude: Double
}
