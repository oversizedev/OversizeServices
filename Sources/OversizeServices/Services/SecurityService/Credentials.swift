//
// Copyright © 2022 Alexander Romanov
// Credentials.swift
//

import Foundation
import OversizeCore

public extension SecureStorageService {
    struct Credentials: Sendable {
        public var login: String
        public var password: String

        public init(login: String, password: String) {
            self.login = login
            self.password = password
        }
    }

    func addCredentials(_ credentials: Credentials, with label: String) {
        var query: [CFString: Any] = [:]
        query[kSecClass] = kSecClassGenericPassword
        query[kSecAttrLabel] = label
        query[kSecAttrAccount] = credentials.login
        query[kSecValueData] = credentials.password.data(using: .utf8)

        do {
            try addItem(query: query)
        } catch {
            logError("Failed to add credentials with label \(label)", error: error)
            return
        }
    }

    func updateCredentials(_ credentials: Credentials, with label: String) {
        deleteCredentials(with: label)
        addCredentials(credentials, with: label)
    }

    func getCredentials(with label: String) -> Credentials? {
        var query: [CFString: Any] = [:]
        query[kSecClass] = kSecClassGenericPassword
        query[kSecAttrLabel] = label

        var result: [CFString: Any]?

        do {
            result = try findItem(query: query)
        } catch {
            logError("Failed to get credentials with label \(label)", error: error)
            return nil
        }

        if let account = result?[kSecAttrAccount] as? String,
           let data = result?[kSecValueData] as? Data,
           let password: String = .init(data: data, encoding: .utf8)
        {
            return Credentials(login: account, password: password)
        } else {
            return nil
        }
    }

    func deleteCredentials(with label: String) {
        var query: [CFString: Any] = [:]
        query[kSecClass] = kSecClassGenericPassword
        query[kSecAttrLabel] = label

        do {
            try deleteItem(query: query)
        } catch {
            logError("Failed to delete credentials with label \(label)", error: error)
            return
        }
    }
}
