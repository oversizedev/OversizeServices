//
// Copyright © 2022 Alexander Romanov
// CredentialsPropertyWrapper.swift
//

import SwiftUI

@propertyWrapper
public struct Credentials: DynamicProperty {
    private let label: String
    private let storage: SecureStorageService = .init()

    public init(_ label: String) {
        self.label = label
    }

    public var wrappedValue: SecureStorageService.Credentials? {
        get { storage.getCredentials(with: label) }
        nonmutating set {
            if let newValue {
                storage.updateCredentials(newValue, with: label)
            } else {
                storage.deleteCredentials(with: label)
            }
        }
    }
}
