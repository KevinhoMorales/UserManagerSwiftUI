//
//  UserListView.swift
//  UserManagerSwiftUI
//
//  Created by Kevinho Morales on 7/5/26.
//

import SwiftUI

// MARK: - UserListView

struct UserListView: View {

    // MARK: Properties

    @StateObject private var viewModel: UserListViewModel
    @EnvironmentObject private var usersChangeNotifier: UsersChangeNotifier

    private let repository: UserRepository

    // MARK: Lifecycle

    init(repository: UserRepository) {
        self.repository = repository
        _viewModel = StateObject(wrappedValue: UserListViewModel(repository: repository))
    }

    // MARK: Body

    var body: some View {
        Group {
            if shouldShowBlockingError {
                errorStateView
            } else if shouldShowInitialLoading {
                loadingStateView
            } else if viewModel.users.isEmpty {
                emptyStateView
            } else {
                usersScrollContent
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Users")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: User.self) { user in
            UserDetailView(user: user, repository: repository)
        }
        .onChange(of: usersChangeNotifier.revision) { _, _ in
            Task { await viewModel.loadUsers() }
        }
        .task {
            await viewModel.loadUsers()
        }
    }

    // MARK: Loading

    private var shouldShowInitialLoading: Bool {
        viewModel.isLoading && viewModel.users.isEmpty && viewModel.errorMessage == nil
    }

    private var loadingStateView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .controlSize(.large)
                .tint(.accentColor)

            Text("Loading users…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
    }

    // MARK: Error

    private var shouldShowBlockingError: Bool {
        viewModel.errorMessage != nil && viewModel.users.isEmpty
    }

    private var errorStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 44, weight: .medium))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.secondary)

            Text("Something went wrong")
                .font(.title3.bold())

            Text(viewModel.errorMessage ?? "")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Button {
                Task { await viewModel.loadUsers() }
            } label: {
                Label("Try again", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 40)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }

    // MARK: Empty

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3.sequence")
                .font(.system(size: 48, weight: .light))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.secondary)

            Text("No users yet")
                .font(.title3.bold())

            Text("Pull down to refresh, or check back after your team has been added.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
        .refreshable {
            await viewModel.loadUsers()
        }
    }

    // MARK: List Content

    private var usersScrollContent: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if let message = viewModel.errorMessage {
                    refreshFailureBanner(message: message)
                }

                ForEach(viewModel.users) { user in
                    NavigationLink(value: user) {
                        UserCardView(user: user)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .refreshable {
            await viewModel.loadUsers()
        }
    }

    // MARK: Subviews

    private func refreshFailureBanner(message: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
                .font(.body)

            VStack(alignment: .leading, spacing: 8) {
                Text("Could not refresh")
                    .font(.subheadline.weight(.semibold))

                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    Task { await viewModel.loadUsers() }
                } label: {
                    Text("Retry")
                        .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.borderless)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.orange.opacity(0.12))
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        UserListView(
            repository: UserRepositoryImpl(
                networkService: AlamofireNetworkService(),
                realmManager: try! RealmManagerImpl(
                    configuration: RealmBootstrap.inMemoryConfiguration(identifier: "list-preview")
                )
            )
        )
        .environmentObject(UsersChangeNotifier())
    }
}
