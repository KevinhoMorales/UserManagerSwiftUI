//
//  UserListViewModel.swift
//  UserManagerSwiftUI
//
//  Created by Kevinho Morales on 7/5/26.
//

import Combine
import Foundation

// MARK: - UserListViewModel

@MainActor
final class UserListViewModel: ObservableObject {

    // MARK: Published State

    @Published private(set) var users: [User] = []
    @Published private(set) var isLoading: Bool
    @Published private(set) var errorMessage: String?
    @Published private(set) var deleteError: String?

    // MARK: Properties

    private let repository: UserRepository

    // MARK: Lifecycle

    init(repository: UserRepository) {
        self.repository = repository
        self.isLoading = true
    }

    // MARK: Actions

    func loadUsers() async {
        isLoading = true
        errorMessage = nil
        deleteError = nil

        do {
            users = try await repository.fetchUsers()
        } catch {
            errorMessage = error.localizedDescription
            if users.isEmpty {
                users = []
            }
        }

        isLoading = false
    }

    func deleteUser(id: Int) async {
        deleteError = nil
        do {
            try await repository.deleteUser(id: id)
            users.removeAll { $0.id == id }
        } catch {
            deleteError = error.localizedDescription
        }
    }
}
