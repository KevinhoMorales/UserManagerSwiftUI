//
//  EditUserViewModel.swift
//  UserManagerSwiftUI
//
//  Created by Kevinho Morales on 7/5/26.
//

import Combine
import Foundation

// MARK: - EditUserViewModel

@MainActor
final class EditUserViewModel: ObservableObject {

    // MARK: Published State

    @Published var name: String
    @Published var email: String
    @Published private(set) var nameError: String?
    @Published private(set) var emailError: String?
    @Published private(set) var isSaving = false
    @Published private(set) var saveError: String?

    // MARK: Properties

    private let original: User
    private let repository: UserRepository

    // MARK: Lifecycle

    init(user: User, repository: UserRepository) {
        self.original = user
        self.repository = repository
        name = user.name
        email = user.email
    }

    // MARK: Validation

    var canSave: Bool {
        nameError == nil
            && emailError == nil
            && trimmed(name).isEmpty == false
            && trimmed(email).isEmpty == false
    }

    func validateFields() {
        nameError = UserFormValidation.validateName(name)
        emailError = UserFormValidation.validateEmail(email)
    }

    // MARK: Actions

    /// Persists changes when valid; returns the updated domain model on success.
    func save() async -> User? {
        validateFields()
        saveError = nil
        guard canSave else { return nil }

        isSaving = true
        defer { isSaving = false }

        let updated = original.updating(
            name: trimmed(name),
            email: trimmed(email)
        )

        do {
            try await repository.updateUser(updated)
            return updated
        } catch {
            saveError = error.localizedDescription
            return nil
        }
    }

    // MARK: Private

    private func trimmed(_ raw: String) -> String {
        raw.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
