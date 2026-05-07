//
//  UserManagerSwiftUIApp.swift
//  UserManagerSwiftUI
//
//  Created by Kevinho Morales on 7/5/26.
//

import SwiftUI

// MARK: - Application

@main
struct UserManagerSwiftUIApp: App {

    // MARK: Properties

    @StateObject private var appCoordinator = AppCoordinator()

    // MARK: Scene

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $appCoordinator.navigationPath) {
                UserListView()
            }
            .environmentObject(appCoordinator)
        }
    }
}
