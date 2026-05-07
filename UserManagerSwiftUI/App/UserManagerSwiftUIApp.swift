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

    // MARK: Composition

    private let usersRepository: UserRepository = UserRepositoryImpl(
        networkService: AlamofireNetworkService()
    )

    // MARK: Properties

    @StateObject private var appCoordinator = AppCoordinator()

    // MARK: Scene

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $appCoordinator.navigationPath) {
                UserListView(repository: usersRepository)
            }
            .environmentObject(appCoordinator)
        }
    }
}
