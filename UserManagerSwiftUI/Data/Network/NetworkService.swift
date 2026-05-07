//
//  NetworkService.swift
//  UserManagerSwiftUI
//
//  Created by Kevinho Morales on 7/5/26.
//

import Foundation

// MARK: - NetworkService

protocol NetworkService: Sendable {

    /// Performs a validated HTTP request and decodes the **successful** response body.
    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        as type: T.Type
    ) async throws -> T
}
