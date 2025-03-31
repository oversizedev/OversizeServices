//
// Copyright © 2022 Alexander Romanov
// Password.swift
//

import Foundation
import OversizeCore
import Security

public extension SecureStorageService {
    func addPassword(_ password: String, for account: String) {
        var query: [CFString: Any] = [:]
        query[kSecClass] = kSecClassGenericPassword
        query[kSecAttrAccount] = account
        // query[kSecAttrAccessGroup] = accessGroup
        query[kSecAttrAccessible] = kSecAttrAccessibleAfterFirstUnlock
        query[kSecValueData] = password.data(using: .utf8)
        do {
            try addItem(query: query)
        } catch {
            logError("Failed to add password with label \(account)", error: error)
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
        // query[kSecAttrAccessGroup] = accessGroup
        var attributesToUpdate: [CFString: Any] = [:]
        attributesToUpdate[kSecValueData] = password.data(using: .utf8)

        do {
            try updateItem(query: query, attributesToUpdate: attributesToUpdate)
        } catch {
            logError("Failed to update password with label \(account)", error: error)
            return
        }
    }

    func getPassword(for account: String) -> String? {
        var query: [CFString: Any] = [:]
        query[kSecClass] = kSecClassGenericPassword
        query[kSecAttrAccount] = account
        // query[kSecAttrAccessGroup] = accessGroup
        var result: [CFString: Any]?

        do {
            result = try findItem(query: query)
        } catch {
            logError("Failed to get password with label \(account)", error: error)
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
        // query[kSecAttrAccessGroup] = accessGroup
        do {
            try deleteItem(query: query)
        } catch {
            logError("Failed to delete password with label \(account)", error: error)
            return
        }
    }
}
