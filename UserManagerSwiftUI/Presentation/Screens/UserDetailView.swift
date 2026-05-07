//
//  UserDetailView.swift
//  UserManagerSwiftUI
//
//  Created by Kevinho Morales on 7/5/26.
//

import SwiftUI

// MARK: - UserDetailView

struct UserDetailView: View {

    // MARK: Properties

    @State private var displayedUser: User
    let repository: UserRepository

    // MARK: Lifecycle

    init(user: User, repository: UserRepository) {
        _displayedUser = State(initialValue: user)
        self.repository = repository
    }

    // MARK: Layout

    private enum Layout {
        static let horizontalPadding: CGFloat = 20
        static let sectionSpacing: CGFloat = 28
        static let avatarSize: CGFloat = 96
        static let cornerRadius: CGFloat = 20
    }

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(spacing: Layout.sectionSpacing) {
                heroHeader

                VStack(alignment: .leading, spacing: 16) {
                    DetailRow(icon: "at", title: "Username", value: displayedUser.username)
                    DetailRow(icon: "envelope", title: "Email", value: displayedUser.email)
                    DetailRow(icon: "phone", title: "Phone", value: displayedUser.phone)
                    DetailRow(icon: "building.2", title: "City", value: displayedUser.city)
                    DetailRow(
                        icon: "location",
                        title: "Coordinates",
                        value: coordinateString
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Layout.horizontalPadding)
            }
            .padding(.vertical, 24)
        }
        .background(.regularMaterial)
        .navigationTitle(displayedUser.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    EditUserView(user: displayedUser, repository: repository) { updated in
                        displayedUser = updated
                    }
                } label: {
                    Text("Edit")
                        .fontWeight(.semibold)
                }
            }
        }
    }

    // MARK: Subviews

    private var heroHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: Layout.cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.accentColor.opacity(0.25),
                                Color.accentColor.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: Layout.avatarSize + 8, height: Layout.avatarSize + 8)

                Circle()
                    .fill(.thickMaterial)
                    .frame(width: Layout.avatarSize, height: Layout.avatarSize)

                Image(systemName: "person.fill")
                    .font(.system(size: 40, weight: .regular))
                    .foregroundStyle(.secondary)
            }

            Text(displayedUser.name)
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text("@\(displayedUser.username)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Layout.horizontalPadding)
    }

    // MARK: Private

    private var coordinateString: String {
        String(format: "%.5f°, %.5f°", displayedUser.latitude, displayedUser.longitude)
    }
}

// MARK: - DetailRow

private struct DetailRow: View {

    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.body.weight(.medium))
                .foregroundStyle(Color.accentColor)
                .frame(width: 28, alignment: .center)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .textCase(.uppercase)

                Text(value)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        }
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        UserDetailView(
            user: User(
                id: 1,
                username: "jdoe",
                name: "Jane Doe",
                email: "jane@example.com",
                phone: "555-0100",
                city: "Austin",
                latitude: 30.27,
                longitude: -97.74
            ),
            repository: UserRepositoryImpl(
                networkService: AlamofireNetworkService(),
                realmManager: try! RealmManagerImpl(
                    configuration: RealmBootstrap.inMemoryConfiguration(identifier: "detail-preview")
                )
            )
        )
        .environmentObject(UsersChangeNotifier())
    }
}
