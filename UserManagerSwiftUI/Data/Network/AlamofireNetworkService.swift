//
//  AlamofireNetworkService.swift
//  UserManagerSwiftUI
//
//  Created by Kevinho Morales on 7/5/26.
//

import Alamofire
import Foundation

// MARK: - AlamofireNetworkService

final class AlamofireNetworkService: NetworkService, @unchecked Sendable {

    // MARK: Properties

    private let session: Session
    private let decoder: JSONDecoder
    private let validStatusCodes = 200..<300

    // MARK: Lifecycle

    init(session: Session = .default, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    // MARK: NetworkService

    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        as type: T.Type
    ) async throws -> T {
        let url = try endpoint.makeURL()

        do {
            return try await session.request(url)
                .validate(statusCode: validStatusCodes)
                .serializingDecodable(T.self, decoder: decoder)
                .value
        } catch let error as AFError {
            throw Self.mapAFError(error)
        } catch {
            throw APIError.transport(underlying: error)
        }
    }

    // MARK: - Private Helpers

    private static func mapAFError(_ error: AFError) -> APIError {
        if case let .responseValidationFailed(reason) = error,
           case let .unacceptableStatusCode(code) = reason {
            return .invalidStatusCode(code)
        }

        if case let .responseSerializationFailed(reason) = error {
            if case .decodingFailed = reason {
                return .decodingFailed
            }
        }

        return .transport(error.localizedDescription)
    }
}
