//
// Copyright © 2022 Alexander Romanov
// Password.swift
//

import Foundation
import Security
import SwiftUI

public extension SecureStorageService {
    func addPassword(_ password: String, for account: String) {
        var query: [CFString: Any] = [:]
        query[kSecClass] = kSecClassGenericPassword
        query[kSecAttrAccount] = account
        query[kSecValueData] = password.data(using: .utf8)

        do {
            try addItem(query: query)
        } catch {
            return
        }
    }

    func updatePassword(_ password: String, for account: String) {
        guard let _ = getPassword(for: account) else {
            addPassword(password, for: account)
            return
        }

        var query: [CFString: Any] = [:]
        query[kSecClass] = kSecClassGenericPassword
        query[kSecAttrAccount] = account

        var attributesToUpdate: [CFString: Any] = [:]
        attributesToUpdate[kSecValueData] = password.data(using: .utf8)

        do {
            try updateItem(query: query, attributesToUpdate: attributesToUpdate)
        } catch {
            return
        }
    }

    func getPassword(for account: String) -> String? {
        var query: [CFString: Any] = [:]
        query[kSecClass] = kSecClassGenericPassword
        query[kSecAttrAccount] = account

        var result: [CFString: Any]?

        do {
            result = try findItem(query: query)
        } catch {
            return nil
        }

        if let data = result?[kSecValueData] as? Data {
            return String(data: data, encoding: .utf8)
        } else {
            return nil
        }
    }

    func deletePassword(for account: String) {
        var query: [CFString: Any] = [:]
        query[kSecClass] = kSecClassGenericPassword
        query[kSecAttrAccount] = account

        do {
            try deleteItem(query: query)
        } catch {
            return
        }
    }
}

@propertyWrapper
public struct SecureStorage: DynamicProperty {
    private let key: String
    private let storage = SecureStorageService()

    public init(_ key: String) {
        self.key = key
    }

    public var wrappedValue: String? {
        get { storage.getPassword(for: key) }
        nonmutating set {
            if let newValue = newValue {
                storage.updatePassword(newValue, for: key)
            } else {
                storage.deletePassword(for: key)
            }
        }
    }
}
