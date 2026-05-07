//
//  RealmManagerImpl.swift
//  UserManagerSwiftUI
//
//  Created by Kevinho Morales on 7/5/26.
//

import Foundation
import RealmSwift

// MARK: - RealmBootstrap

/// Factory for `Realm.Configuration` values used by the app and SwiftUI previews.
enum RealmBootstrap {

    /// On-disk default configuration for the application target.
    static func persistedConfiguration() -> Realm.Configuration {
        var configuration = Realm.Configuration(
            schemaVersion: 2,
            migrationBlock: { _, _ in }
        )
        configuration.objectTypes = [RealmUserObject.self, DeletedUserIdObject.self]
        return configuration
    }

    /// In-memory store for tests and previews.
    static func inMemoryConfiguration(identifier: String) -> Realm.Configuration {
        var configuration = Realm.Configuration(inMemoryIdentifier: identifier)
        configuration.objectTypes = [RealmUserObject.self, DeletedUserIdObject.self]
        configuration.schemaVersion = 2
        return configuration
    }
}

// MARK: - RealmManagerImpl

@MainActor
final class RealmManagerImpl: RealmManager {

    // MARK: Properties

    private let realm: Realm

    // MARK: Lifecycle

    init(configuration: Realm.Configuration) throws {
        self.realm = try Realm(configuration: configuration)
    }

    // MARK: RealmManager

    func saveUser(_ user: User) throws {
        guard fetchDeletedUserIds().contains(user.id) == false else {
            return
        }
        try realm.write {
            let object = RealmUserObject(domain: user)
            realm.add(object, update: .modified)
        }
    }

    func saveUsers(_ users: [User]) throws {
        let tombstones = fetchDeletedUserIds()
        try realm.write {
            for user in users where tombstones.contains(user.id) == false {
                let object = RealmUserObject(domain: user)
                realm.add(object, update: .modified)
            }
        }
    }

    func fetchUsers() throws -> [User] {
        let tombstones = fetchDeletedUserIds()
        let objects = realm.objects(RealmUserObject.self).sorted(byKeyPath: "id")
        return objects.compactMap { object in
            guard tombstones.contains(object.id) == false else {
                return nil
            }
            return User(realmObject: object)
        }
    }

    func updateUser(_ user: User) throws {
        try saveUser(user)
    }

    func logicallyDeleteUser(id: Int) throws {
        try realm.write {
            if let cached = realm.object(ofType: RealmUserObject.self, forPrimaryKey: id) {
                realm.delete(cached)
            }
            let tombstone = DeletedUserIdObject()
            tombstone.userId = id
            realm.add(tombstone, update: .modified)
        }
    }

    func userExists(id: Int) -> Bool {
        realm.object(ofType: RealmUserObject.self, forPrimaryKey: id) != nil
    }

    func fetchDeletedUserIds() -> Set<Int> {
        Set(realm.objects(DeletedUserIdObject.self).map(\.userId))
    }
}
