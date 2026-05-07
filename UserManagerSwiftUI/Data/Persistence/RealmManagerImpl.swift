//
//  RealmManagerImpl.swift
//  UserManagerSwiftUI
//
//  Created by Kevinho Morales on 7/5/26.
//

import Foundation
import RealmSwift

// MARK: - RealmManagerImpl

@MainActor
final class RealmManagerImpl: RealmManager {

    // MARK: Properties

    private let realm: Realm

    // MARK: Lifecycle

    init(configuration: Realm.Configuration = RealmManagerImpl.makeDefaultConfiguration()) throws {
        self.realm = try Realm(configuration: configuration)
    }

    // MARK: RealmManager

    func saveUser(_ user: User) throws {
        try realm.write {
            let object = RealmUserObject(domain: user)
            realm.add(object, update: .modified)
        }
    }

    func saveUsers(_ users: [User]) throws {
        try realm.write {
            for user in users {
                let object = RealmUserObject(domain: user)
                realm.add(object, update: .modified)
            }
        }
    }

    func fetchUsers() throws -> [User] {
        let objects = realm.objects(RealmUserObject.self).sorted(byKeyPath: "id")
        return objects.map { User(realmObject: $0) }
    }

    func updateUser(_ user: User) throws {
        try saveUser(user)
    }

    func deleteUser(id: Int) throws {
        guard let object = realm.object(ofType: RealmUserObject.self, forPrimaryKey: id) else {
            return
        }
        try realm.write {
            realm.delete(object)
        }
    }

    func userExists(id: Int) throws -> Bool {
        realm.object(ofType: RealmUserObject.self, forPrimaryKey: id) != nil
    }

    // MARK: - Private

    private static func makeDefaultConfiguration() -> Realm.Configuration {
        var configuration = Realm.Configuration(schemaVersion: 1)
        configuration.objectTypes = [RealmUserObject.self]
        return configuration
    }
}

// MARK: - RealmBootstrap

/// Shared Realm configuration helpers (e.g. in-memory stores for SwiftUI previews).
enum RealmBootstrap {

    static func inMemoryConfiguration(identifier: String) -> Realm.Configuration {
        var configuration = Realm.Configuration(inMemoryIdentifier: identifier)
        configuration.objectTypes = [RealmUserObject.self]
        configuration.schemaVersion = 1
        return configuration
    }
}
