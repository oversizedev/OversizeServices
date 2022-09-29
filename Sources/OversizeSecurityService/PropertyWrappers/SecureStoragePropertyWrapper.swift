//
// Copyright © 2022 Alexander Romanov
// SecureStoragePropertyWrapper.swift
//

import SwiftUI

@propertyWrapper
public struct SecureStorage: DynamicProperty {
    private let key: String
    private let storage: SecureStorageService = .init()

    public init(_ key: String) {
        self.key = key
    }

    public var wrappedValue: String? {
        get { storage.getPassword(for: key) }
        nonmutating set {
            if let newValue {
                storage.updatePassword(newValue, for: key)
            } else {
                storage.deletePassword(for: key)
            }
        }
    }
}
