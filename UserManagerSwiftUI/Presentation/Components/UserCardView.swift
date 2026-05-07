//
//  UserCardView.swift
//  UserManagerSwiftUI
//
//  Created by Kevinho Morales on 7/5/26.
//

import SwiftUI

// MARK: - UserCardView

struct UserCardView: View {

    // MARK: Properties

    let user: User

    // MARK: Layout

    private enum Layout {
        static let cornerRadius: CGFloat = 16
        static let avatarSize: CGFloat = 56
        static let contentSpacing: CGFloat = 6
        static let horizontalSpacing: CGFloat = 16
        static let cardPadding: CGFloat = 16
        static let shadowOpacity: Double = 0.08
        static let shadowRadius: CGFloat = 12
        static let shadowYOffset: CGFloat = 4
    }

    // MARK: Body

    var body: some View {
        HStack(alignment: .top, spacing: Layout.horizontalSpacing) {
            profilePlaceholder

            VStack(alignment: .leading, spacing: Layout.contentSpacing) {
                Text(user.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                secondaryRow(icon: "at", text: user.username)

                secondaryRow(icon: "envelope", text: user.email)

                secondaryRow(icon: "phone", text: user.phone)

                secondaryRow(icon: "mappin.and.ellipse", text: user.city)
            }

            Spacer(minLength: 0)
        }
        .padding(Layout.cardPadding)
        .background {
            RoundedRectangle(cornerRadius: Layout.cornerRadius, style: .continuous)
                .fill(.background)
                .shadow(
                    color: .black.opacity(Layout.shadowOpacity),
                    radius: Layout.shadowRadius,
                    x: 0,
                    y: Layout.shadowYOffset
                )
        }
    }

    // MARK: Subviews

    private var profilePlaceholder: some View {
        ZStack {
            Circle()
                .fill(.quaternary)

            Image(systemName: "person.fill")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(.tertiary)
        }
        .frame(width: Layout.avatarSize, height: Layout.avatarSize)
    }

    @ViewBuilder
    private func secondaryRow(icon: String, text: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Image(systemName: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
                .frame(width: 16, alignment: .center)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
    }
}

// MARK: - Previews

#Preview {
    UserCardView(
        user: User(
            id: 1,
            username: "jdoe",
            name: "Jane Doe",
            email: "jane@example.com",
            phone: "555-0100",
            city: "Austin",
            latitude: 30.27,
            longitude: -97.74
        )
    )
    .padding()
    .background(Color(red: 0.95, green: 0.95, blue: 0.97))
}
