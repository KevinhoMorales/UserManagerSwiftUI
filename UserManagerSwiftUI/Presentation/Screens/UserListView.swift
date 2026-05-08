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
        .animation(.easeOut(duration: 0.22), value: shouldShowBlockingError)
        .animation(.easeOut(duration: 0.22), value: shouldShowInitialLoading)
        .animation(.easeOut(duration: 0.22), value: viewModel.users.isEmpty)
        .contentTransition(.opacity)
        .navigationTitle(L10n.UserList.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink {
                    CreateUserView(locationManager: locationManager)
                } label: {
                    Label(L10n.UserList.createUser, systemImage: "plus.circle.fill")
                }
                .accessibilityLabel(L10n.UserList.createUserAccessibility)
            }
        }
        .navigationDestination(for: User.self) { user in
            UserDetailView(user: user, repository: repository)
        }
        .confirmationDialog(
            L10n.UserList.deleteTitle,
            isPresented: Binding(
                get: { userPendingDeletion != nil },
                set: { if $0 == false { userPendingDeletion = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button(L10n.Common.delete, role: .destructive) {
                if let user = userPendingDeletion {
                    Task { await viewModel.deleteUser(id: user.id) }
                }
                userPendingDeletion = nil
            }
            Button(L10n.Common.cancel, role: .cancel) {
                userPendingDeletion = nil
            }
        } message: {
            if let user = userPendingDeletion {
                Text(L10n.UserList.deleteMessage(name: user.name))
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
        VStack(spacing: AppMetrics.stackSpacing) {
            ProgressView()
                .controlSize(.large)
                .tint(.accentColor)
                .accessibilityLabel(L10n.UserList.loading)

            Text(L10n.UserList.loading)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(AppMetrics.screenEdgePadding)
    }

    // MARK: Error

    private var shouldShowBlockingError: Bool {
        viewModel.errorMessage != nil && viewModel.users.isEmpty
    }

    private var errorStateView: some View {
        VStack(spacing: AppMetrics.stackSpacing) {
            Image(systemName: "wifi.exclamationmark")
                .font(.largeTitle)
                .imageScale(.large)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            Text(L10n.UserList.errorTitle)
                .font(.title3.bold())
                .multilineTextAlignment(.center)

            Text(viewModel.errorMessage ?? "")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppMetrics.screenEdgePadding)

            Button {
                Task { await viewModel.loadUsers() }
            } label: {
                Label(L10n.Common.tryAgain, systemImage: "arrow.clockwise")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 40)
            .padding(.top, AppMetrics.tightSpacing)
            .contentShape(Rectangle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(AppMetrics.screenEdgePadding)
    }

    // MARK: Empty

    private var emptyStateView: some View {
        VStack(spacing: AppMetrics.stackSpacing) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.largeTitle)
                .imageScale(.large)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            Text(L10n.UserList.emptyTitle)
                .font(.title3.bold())
                .multilineTextAlignment(.center)

            Text(L10n.UserList.emptyMessage)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppMetrics.screenEdgePadding)

            Button {
                Task { await viewModel.loadUsers() }
            } label: {
                Label(L10n.UserList.reload, systemImage: "arrow.clockwise.circle")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .contentShape(Rectangle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(AppMetrics.screenEdgePadding)
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
                .listRowInsets(EdgeInsets(top: AppMetrics.tightSpacing, leading: AppMetrics.stackSpacing, bottom: AppMetrics.tightSpacing, trailing: AppMetrics.stackSpacing))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            if let deleteMessage = viewModel.deleteError {
                Section {
                    deleteFailureBanner(message: deleteMessage)
                }
                .listRowInsets(EdgeInsets(top: AppMetrics.tightSpacing, leading: AppMetrics.stackSpacing, bottom: AppMetrics.tightSpacing, trailing: AppMetrics.stackSpacing))
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
                            Label(L10n.Common.delete, systemImage: "trash")
                        }
                        .accessibilityLabel("\(L10n.Common.delete), \(user.name)")
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: AppMetrics.tightSpacing, leading: AppMetrics.stackSpacing, bottom: AppMetrics.tightSpacing, trailing: AppMetrics.stackSpacing))
                }
            }
        }
        .listStyle(.plain)
        .listSectionSpacing(AppMetrics.formSectionSpacing)
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
                .font(.body.weight(.medium))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: AppMetrics.tightSpacing) {
                Text(L10n.UserList.refreshFailed)
                    .font(.subheadline.weight(.semibold))

                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    Task { await viewModel.loadUsers() }
                } label: {
                    Text(L10n.Common.retry)
                        .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.borderless)
                .padding(.top, 2)
            }

            Spacer(minLength: 0)
        }
        .padding(AppMetrics.stackSpacing)
        .background {
            RoundedRectangle(cornerRadius: AppMetrics.bannerCornerRadius, style: .continuous)
                .fill(.orange.opacity(0.12))
        }
        .accessibilityElement(children: .combine)
    }

    private func deleteFailureBanner(message: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.red)
                .font(.body.weight(.medium))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                Text(L10n.UserList.deleteFailed)
                    .font(.subheadline.weight(.semibold))
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(AppMetrics.stackSpacing)
        .background {
            RoundedRectangle(cornerRadius: AppMetrics.bannerCornerRadius, style: .continuous)
                .fill(.red.opacity(0.1))
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
            ),
            locationManager: CoreLocationManager()
        )
        .environmentObject(UsersChangeNotifier())
    }
}
