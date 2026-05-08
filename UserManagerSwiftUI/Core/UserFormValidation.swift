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

    static func validateName(_ raw: String) -> String? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return String(localized: "validation.name.empty")
        }
        return nil
    }

    // MARK: Email

    static func validateEmail(_ raw: String) -> String? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return String(localized: "validation.email.empty")
        }
        guard isValidEmailFormat(trimmed) else {
            return String(localized: "validation.email.invalid")
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
