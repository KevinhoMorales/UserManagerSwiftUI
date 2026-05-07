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

    func deleteUser(id: Int) throws

    func userExists(id: Int) throws -> Bool
}
