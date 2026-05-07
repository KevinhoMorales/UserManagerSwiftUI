//
//  UsersChangeNotifier.swift
//  UserManagerSwiftUI
//
//  Created by Kevinho Morales on 7/5/26.
//

import Combine
import Foundation

// MARK: - UsersChangeNotifier

/// Lightweight signal for cross-screen list refresh after local persistence changes.
@MainActor
final class UsersChangeNotifier: ObservableObject {

    // MARK: Properties

    /// Increments whenever persisted user data should be reloaded from the repository.
    @Published private(set) var revision: UInt = 0

    // MARK: Actions

    func notifyUsersChanged() {
        revision &+= 1
    }
}
