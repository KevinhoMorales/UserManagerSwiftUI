//
//  DeletedUserIdObject.swift
//  UserManagerSwiftUI
//
//  Created by Kevinho Morales on 7/5/26.
//

import Foundation
import RealmSwift

// MARK: - DeletedUserIdObject

/// Tombstone for users removed on this device so remote sync does not bring them back.
final class DeletedUserIdObject: Object {

    @Persisted(primaryKey: true) var userId: Int
}
