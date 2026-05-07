//
//  APIEndpoint.swift
//  UserManagerSwiftUI
//
//  Created by Kevinho Morales on 7/5/26.
//

import Foundation

// MARK: - APIEndpoint

enum APIEndpoint: Sendable {

    case users

    // MARK: Properties

    private static let baseURLString = "https://jsonplaceholder.typicode.com"

    // MARK: URL Resolution

    func makeURL() throws -> URL {
        switch self {
        case .users:
            guard let url = URL(string: "\(Self.baseURLString)/users") else {
                throw APIError.invalidURL
            }
            return url
        }
    }
}
