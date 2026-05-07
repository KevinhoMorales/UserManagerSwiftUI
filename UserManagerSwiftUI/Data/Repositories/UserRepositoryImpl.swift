//
//  UserRepositoryImpl.swift
//  UserManagerSwiftUI
//
//  Created by Kevinho Morales on 7/5/26.
//

import Foundation

// MARK: - UserRepositoryImpl

final class UserRepositoryImpl: UserRepository {

    // MARK: Properties

    private let networkService: NetworkService

    // MARK: Lifecycle

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    // MARK: UserRepository

    func fetchUsers() async throws -> [User] {
        let usersDTO: [UserDTO] = try await networkService.request(.users, as: [UserDTO].self)
        return usersDTO.map { $0.toDomain() }
    }
}
