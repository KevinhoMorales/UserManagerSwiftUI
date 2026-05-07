//
//  EditUserView.swift
//  UserManagerSwiftUI
//
//  Created by Kevinho Morales on 7/5/26.
//

import SwiftUI

// MARK: - EditUserView

struct EditUserView: View {

    // MARK: Properties

    @StateObject private var viewModel: EditUserViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var usersChangeNotifier: UsersChangeNotifier

    private let onSaved: (User) -> Void

    // MARK: Lifecycle

    init(
        user: User,
        repository: UserRepository,
        onSaved: @escaping (User) -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: EditUserViewModel(user: user, repository: repository)
        )
        self.onSaved = onSaved
    }

    // MARK: Body

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $viewModel.name)
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)
                    .onChange(of: viewModel.name) { _, _ in
                        viewModel.validateFields()
                    }

                if let nameError = viewModel.nameError {
                    validationHint(nameError)
                }
            } header: {
                Text("Name")
            }

            Section {
                TextField("Email", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .onChange(of: viewModel.email) { _, _ in
                        viewModel.validateFields()
                    }

                if let emailError = viewModel.emailError {
                    validationHint(emailError)
                }
            } header: {
                Text("Email")
            }

            if let saveError = viewModel.saveError {
                Section {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundStyle(.red)
                        Text(saveError)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .disabled(viewModel.isSaving)
        .navigationTitle("Edit User")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
                .disabled(viewModel.isSaving)
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task { await performSave() }
                }
                .disabled(viewModel.canSave == false || viewModel.isSaving)
            }
        }
        .onAppear {
            viewModel.validateFields()
        }
        .overlay {
            if viewModel.isSaving {
                Color.black.opacity(0.08)
                    .ignoresSafeArea()
                ProgressView("Saving…")
                    .padding(20)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    // MARK: Private

    private func validationHint(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(.red)
            .accessibilityLabel(text)
    }

    private func performSave() async {
        if let updated = await viewModel.save() {
            usersChangeNotifier.notifyUsersChanged()
            onSaved(updated)
            dismiss()
        }
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        EditUserView(
            user: User(
                id: 1,
                username: "jdoe",
                name: "Jane Doe",
                email: "jane@example.com",
                phone: "555",
                city: "Austin",
                latitude: 0,
                longitude: 0
            ),
            repository: UserRepositoryImpl(
                networkService: AlamofireNetworkService(),
                realmManager: try! RealmManagerImpl(
                    configuration: RealmBootstrap.inMemoryConfiguration(identifier: "edit-preview")
                )
            ),
            onSaved: { _ in }
        )
        .environmentObject(UsersChangeNotifier())
    }
}
