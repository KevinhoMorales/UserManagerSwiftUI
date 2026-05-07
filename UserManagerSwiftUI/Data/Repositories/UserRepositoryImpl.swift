//
//  UserRepositoryImpl.swift
//  UserManagerSwiftUI
//
//  Created by Kevinho Morales on 7/5/26.
//

import Foundation

// MARK: - UserRepositoryImpl

@MainActor
final class UserRepositoryImpl: UserRepository {

    // MARK: Properties

    private let networkService: NetworkService
    private let realmManager: RealmManager

    // MARK: Lifecycle

    init(networkService: NetworkService, realmManager: RealmManager) {
        self.networkService = networkService
        self.realmManager = realmManager
    }

    // MARK: UserRepository

    func fetchUsers() async throws -> [User] {
        do {
            let usersDTO: [UserDTO] = try await networkService.request(.users, as: [UserDTO].self)
            let users = usersDTO.map { $0.toDomain() }
            try realmManager.saveUsers(users)
            return users
        } catch {
            let cached = (try? realmManager.fetchUsers()) ?? []
            guard cached.isEmpty == false else {
                throw error
            }
            return cached
        }
    }

    func updateUser(_ user: User) async throws {
        try realmManager.updateUser(user)
    }
}
