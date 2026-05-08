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

    // MARK: URL Resolution

    nonisolated func makeURL() throws -> URL {
        let baseURLString = "https://jsonplaceholder.typicode.com"
        switch self {
        case .users:
            guard let url = URL(string: "\(baseURLString)/users") else {
                throw APIError.invalidURL
            }
            return url
        }
    }
}
