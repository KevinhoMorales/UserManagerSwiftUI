//
//  UserRepository.swift
//  UserManagerSwiftUI
//
//  Created by Kevinho Morales on 7/5/26.
//

import Foundation

// MARK: - UserRepository

@MainActor
protocol UserRepository: AnyObject {

    func fetchUsers() async throws -> [User]

    func updateUser(_ user: User) async throws

    /// Logical delete on this device (tombstone + local cache cleanup).
    func deleteUser(id: Int) async throws
}
