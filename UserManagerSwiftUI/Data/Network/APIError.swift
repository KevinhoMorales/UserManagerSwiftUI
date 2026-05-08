//
//  APIError.swift
//  UserManagerSwiftUI
//
//  Created by Kevinho Morales on 7/5/26.
//

import Foundation

// MARK: - APIError

enum APIError: Error, Equatable, Sendable {

    case invalidURL
    case invalidStatusCode(Int)
    case decodingFailed
    case transport(String)

    // MARK: Factory Methods

    static func transport(underlying error: Error) -> APIError {
        .transport((error as NSError).localizedDescription)
    }
}

// MARK: - LocalizedError

extension APIError: LocalizedError {

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return String(localized: "error.api.invalid_url")
        case .invalidStatusCode(let code):
            return String(format: String(localized: "error.api.invalid_status"), code)
        case .decodingFailed:
            return String(localized: "error.api.decoding_failed")
        case .transport(let message):
            return message
        }
    }
}
