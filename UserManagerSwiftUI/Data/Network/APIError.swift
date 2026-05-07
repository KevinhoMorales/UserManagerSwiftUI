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
            return "The request URL is invalid."
        case .invalidStatusCode(let code):
            return "The server returned an unexpected response (HTTP \(code))."
        case .decodingFailed:
            return "The response could not be decoded."
        case .transport(let message):
            return message
        }
    }
}
