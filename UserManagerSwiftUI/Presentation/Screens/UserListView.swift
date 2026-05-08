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

    @State private var userPendingDeletion: User?

    private let repository: UserRepository
    private let locationManager: CoreLocationManager

    // MARK: Lifecycle

    init(repository: UserRepository, locationManager: CoreLocationManager) {
        self.repository = repository
        self.locationManager = locationManager
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
                usersListContent
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Users")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink {
                    CreateUserView(locationManager: locationManager)
                } label: {
                    Label("Create user", systemImage: "plus.circle.fill")
                }
                .accessibilityLabel("Create user")
            }
        }
        .navigationDestination(for: User.self) { user in
            UserDetailView(user: user, repository: repository)
        }
        .confirmationDialog(
            "Remove this user?",
            isPresented: Binding(
                get: { userPendingDeletion != nil },
                set: { if $0 == false { userPendingDeletion = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let user = userPendingDeletion {
                    Task { await viewModel.deleteUser(id: user.id) }
                }
                userPendingDeletion = nil
            }
            Button("Cancel", role: .cancel) {
                userPendingDeletion = nil
            }
        } message: {
            if let user = userPendingDeletion {
                Text("\(user.name) will be hidden on this device and will not return after you refresh or go offline.")
            }
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
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.minus")
                .font(.system(size: 48, weight: .light))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.secondary)

            Text("No users to show")
                .font(.title3.bold())

            Text("Everyone may have been removed on this device, or nothing has loaded yet. Pull down to refresh, or reload from the server.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)

            Button {
                Task { await viewModel.loadUsers() }
            } label: {
                Label("Reload from server", systemImage: "arrow.clockwise.circle")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
        .refreshable {
            await viewModel.loadUsers()
        }
    }

    // MARK: List Content

    private var usersListContent: some View {
        List {
            if let message = viewModel.errorMessage {
                Section {
                    refreshFailureBanner(message: message)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            if let deleteMessage = viewModel.deleteError {
                Section {
                    deleteFailureBanner(message: deleteMessage)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            Section {
                ForEach(viewModel.users) { user in
                    NavigationLink(value: user) {
                        UserCardView(user: user)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            userPendingDeletion = user
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
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

    private func deleteFailureBanner(message: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.red)
                .font(.body)

            VStack(alignment: .leading, spacing: 6) {
                Text("Could not remove user")
                    .font(.subheadline.weight(.semibold))
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.red.opacity(0.1))
        }
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
            ),
            locationManager: CoreLocationManager()
        )
        .environmentObject(UsersChangeNotifier())
    }
}
