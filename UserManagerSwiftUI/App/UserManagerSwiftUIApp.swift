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

    @StateObject private var appCoordinator: AppCoordinator
    @StateObject private var usersChangeNotifier: UsersChangeNotifier
    private let usersRepository: UserRepository

    // MARK: Lifecycle

    init() {
        let realmManager: RealmManager
        do {
            realmManager = try RealmManagerImpl()
        } catch {
            fatalError("Could not open the local store: \(error.localizedDescription)")
        }

        _appCoordinator = StateObject(wrappedValue: AppCoordinator())
        _usersChangeNotifier = StateObject(wrappedValue: UsersChangeNotifier())

        usersRepository = UserRepositoryImpl(
            networkService: AlamofireNetworkService(),
            realmManager: realmManager
        )
    }

    // MARK: Scene

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $appCoordinator.navigationPath) {
                UserListView(repository: usersRepository)
            }
            .environmentObject(appCoordinator)
            .environmentObject(usersChangeNotifier)
        }
    }
}
