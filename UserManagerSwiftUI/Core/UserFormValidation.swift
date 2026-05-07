//
//  UserFormValidation.swift
//  UserManagerSwiftUI
//
//  Created by Kevinho Morales on 7/5/26.
//

import Foundation

// MARK: - UserFormValidation

enum UserFormValidation: Sendable {

    // MARK: Name

    /// Returns a user-visible validation message, or `nil` when the value is valid.
    static func validateName(_ raw: String) -> String? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return "Name cannot be empty."
        }
        return nil
    }

    // MARK: Email

    /// Returns a user-visible validation message, or `nil` when the value is valid.
    static func validateEmail(_ raw: String) -> String? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return "Email cannot be empty."
        }
        guard isValidEmailFormat(trimmed) else {
            return "Enter a valid email address."
        }
        return nil
    }

    // MARK: Private

    private static func isValidEmailFormat(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        return email.range(
            of: pattern,
            options: [.regularExpression, .caseInsensitive]
        ) != nil
    }
}
