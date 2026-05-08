//
//  L10n.swift
//  UserManagerSwiftUI
//
//  Created by Kevinho Morales on 7/5/26.
//

import Foundation

// MARK: - L10n

enum L10n {

    // MARK: Common

    enum Common {
        static var ok: String { String(localized: "common.ok") }
        static var cancel: String { String(localized: "common.cancel") }
        static var delete: String { String(localized: "common.delete") }
        static var retry: String { String(localized: "common.retry") }
        static var save: String { String(localized: "common.save") }
        static var edit: String { String(localized: "common.edit") }
        static var tryAgain: String { String(localized: "common.try_again") }
    }

    // MARK: User List

    enum UserList {
        static var title: String { String(localized: "user_list.title") }
        static var createUser: String { String(localized: "user_list.create_user") }
        static var createUserAccessibility: String { String(localized: "user_list.create_user.a11y") }
        static var loading: String { String(localized: "user_list.loading") }
        static var errorTitle: String { String(localized: "user_list.error.title") }
        static var emptyTitle: String { String(localized: "user_list.empty.title") }
        static var emptyMessage: String { String(localized: "user_list.empty.message") }
        static var reload: String { String(localized: "user_list.reload") }
        static var deleteTitle: String { String(localized: "user_list.delete.title") }
        static func deleteMessage(name: String) -> String {
            String(format: String(localized: "user_list.delete.message_format"), name)
        }
        static var refreshFailed: String { String(localized: "user_list.refresh_failed") }
        static var deleteFailed: String { String(localized: "user_list.delete_failed") }
    }

    // MARK: Create User

    enum CreateUser {
        static var title: String { String(localized: "create_user.title") }
        static var intro: String { String(localized: "create_user.intro") }
        static var getLocation: String { String(localized: "create_user.get_location") }
        static var locationFooter: String { String(localized: "create_user.location_footer") }
        static var loading: String { String(localized: "create_user.loading") }
        static var alertCoordinates: String { String(localized: "create_user.alert.coordinates") }
        static var alertLocation: String { String(localized: "create_user.alert.location") }
        static func coordinatesBody(latitude: Double, longitude: Double) -> String {
            String(format: String(localized: "create_user.coordinates_format"), latitude, longitude)
        }
    }

    // MARK: User Detail

    enum UserDetail {
        static var username: String { String(localized: "user_detail.field.username") }
        static var email: String { String(localized: "user_detail.field.email") }
        static var phone: String { String(localized: "user_detail.field.phone") }
        static var city: String { String(localized: "user_detail.field.city") }
        static var coordinates: String { String(localized: "user_detail.field.coordinates") }
        static func coordinatesValue(latitude: Double, longitude: Double) -> String {
            String(format: String(localized: "user_detail.coordinates_format"), locale: Locale.current, latitude, longitude)
        }
    }

    // MARK: Edit User

    enum EditUser {
        static var title: String { String(localized: "edit_user.title") }
        static var nameSection: String { String(localized: "edit_user.section.name") }
        static var emailSection: String { String(localized: "edit_user.section.email") }
        static var namePlaceholder: String { String(localized: "edit_user.placeholder.name") }
        static var emailPlaceholder: String { String(localized: "edit_user.placeholder.email") }
        static var saving: String { String(localized: "edit_user.saving") }
    }
}
