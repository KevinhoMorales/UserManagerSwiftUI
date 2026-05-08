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
                TextField(L10n.EditUser.namePlaceholder, text: $viewModel.name)
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)
                    .onChange(of: viewModel.name) { _, _ in
                        viewModel.validateFields()
                    }

                if let nameError = viewModel.nameError {
                    validationHint(nameError)
                }
            } header: {
                Text(L10n.EditUser.nameSection)
            }

            Section {
                TextField(L10n.EditUser.emailPlaceholder, text: $viewModel.email)
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
                Text(L10n.EditUser.emailSection)
            }

            if let saveError = viewModel.saveError {
                Section {
                    HStack(alignment: .top, spacing: AppMetrics.tightSpacing) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundStyle(.red)
                            .accessibilityHidden(true)
                        Text(saveError)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .disabled(viewModel.isSaving)
        .navigationTitle(L10n.EditUser.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(L10n.Common.cancel) {
                    dismiss()
                }
                .disabled(viewModel.isSaving)
            }

            ToolbarItem(placement: .confirmationAction) {
                Button(L10n.Common.save) {
                    Task { await performSave() }
                }
                .fontWeight(.semibold)
                .disabled(viewModel.canSave == false || viewModel.isSaving)
            }
        }
        .onAppear {
            viewModel.validateFields()
        }
        .overlay {
            if viewModel.isSaving {
                ZStack {
                    Color.black.opacity(0.08)
                        .ignoresSafeArea()
                    VStack(spacing: 12) {
                        ProgressView()
                            .controlSize(.large)
                        Text(L10n.EditUser.saving)
                            .font(.callout)
                            .multilineTextAlignment(.center)
                    }
                    .padding(AppMetrics.loadingPanelPadding)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: AppMetrics.loadingPanelCornerRadius))
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.isSaving)
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
