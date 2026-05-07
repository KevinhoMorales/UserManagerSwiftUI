//
//  UserRepository.swift
//  UserManagerSwiftUI
//
//  Created by Kevinho Morales on 7/5/26.
//

import Foundation

// MARK: - UserRepository

protocol UserRepository: Sendable {

    func fetchUsers() async throws -> [User]
}
