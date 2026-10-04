//
// Copyright © 2022 Alexander Romanov
// SecureStoragePropertyWrapper.swift
//

import OversizeCore
import SwiftUI

@propertyWrapper
public struct SecureStorage: DynamicProperty {
    private let key: String
    private let keychain = Keychain(service: nil)

    public init(_ key: String) {
        self.key = key
    }

    public var wrappedValue: String? {
        get {
            do {
                return try keychain.string(forKey: key)
            } catch {
                Log.error("Failed to read secure value for \(key)", error: error)
                return nil
            }
        }
        nonmutating set {
            do {
                if let newValue {
                    try keychain.set(newValue, forKey: key)
                } else {
                    try keychain.remove(forKey: key)
                }
            } catch {
                Log.error("Failed to store secure value for \(key)", error: error)
            }
        }
    }
}
