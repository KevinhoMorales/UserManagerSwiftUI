//
//  AppCoordinator.swift
//  UserManagerSwiftUI
//
//  Created by Kevinho Morales on 7/5/26.
//

import Combine
import SwiftUI

// MARK: - AppCoordinator

@MainActor
final class AppCoordinator: ObservableObject {

    // MARK: Navigation State

    @Published var navigationPath = NavigationPath()

    // MARK: - Placeholder Navigation

    /// Presents the user list as root flow segment (no-op until routes are defined).
    func showUserList() {
        // Intentionally empty: wire destination types when feature routes exist.
    }

    /// Navigates to user detail for the given identifier.
    func showUserDetail(id _: String) {
        // Intentionally empty: append `NavigationPath` values when destinations are modeled.
    }

    /// Presents a modal or sheet flow root (placeholder).
    func presentUserComposer() {
        // Intentionally empty: integrate with sheet/fullScreenCover coordination later.
    }

    /// Removes the last pushed destination from the stack when possible.
    func pop() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
    }

    /// Clears the navigation stack back to the root view.
    func popToRoot() {
        navigationPath = NavigationPath()
    }
}
