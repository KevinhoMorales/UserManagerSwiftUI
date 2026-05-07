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

    // MARK: Lifecycle

    init(repository: UserRepository) {
        _viewModel = StateObject(wrappedValue: UserListViewModel(repository: repository))
    }

    // MARK: Body

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.users.isEmpty {
                ProgressView("Loading users…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let message = viewModel.errorMessage {
                ContentUnavailableView(
                    "Could not load users",
                    systemImage: "wifi.exclamationmark",
                    description: Text(message)
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                listContent
            }
        }
        .navigationTitle("Users")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadUsers()
        }
    }

    // MARK: Subviews

    private var listContent: some View {
        List {
            Section {
                Text("Browse and manage your team members.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .listRowInsets(EdgeInsets(top: 12, leading: 20, bottom: 8, trailing: 20))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }

            Section {
                ForEach(viewModel.users) { user in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.name)
                            .font(.headline)
                        Text("@\(user.username)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(user.email)
                            .font(.subheadline)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .listStyle(.insetGrouped)
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .padding(12)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        UserListView(
            repository: UserRepositoryImpl(
                networkService: AlamofireNetworkService()
            )
        )
    }
}
