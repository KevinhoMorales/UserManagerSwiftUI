//
//  RealmManager.swift
//  UserManagerSwiftUI
//
//  Created by Kevinho Morales on 7/5/26.
//

import Foundation

// MARK: - RealmManager

@MainActor
protocol RealmManager: AnyObject {

    func saveUser(_ user: User) throws

    func saveUsers(_ users: [User]) throws

    func fetchUsers() throws -> [User]

    func updateUser(_ user: User) throws

    /// Records a logical delete (tombstone) and removes the cached `RealmUserObject` row when present.
    func logicallyDeleteUser(id: Int) throws

    func userExists(id: Int) -> Bool

    func fetchDeletedUserIds() -> Set<Int>
}
