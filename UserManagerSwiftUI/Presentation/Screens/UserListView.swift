//
//  UserListView.swift
//  UserManagerSwiftUI
//
//  Created by Kevinho Morales on 7/5/26.
//

import SwiftUI
import UIKit

// MARK: - UserListView

struct UserListView: View {

    // MARK: Constants

    private enum Layout {
        static let horizontalInset: CGFloat = 24
        static let titleSubtitleSpacing: CGFloat = 8
        static let topPadding: CGFloat = 8
    }

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Layout.titleSubtitleSpacing) {
                Text("Users")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.primary)

                Text("Browse and manage your team members. Content will appear here.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Layout.horizontalInset)
            .padding(.top, Layout.topPadding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(uiColor: UIColor.systemGroupedBackground))
    }
}

// MARK: - Previews

#Preview {
    UserListView()
}
