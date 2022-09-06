//
// Copyright © 2022 Alexander Romanov
// Credentials.swift
//

import Foundation

public extension SecureStorageService {
    struct Credentials {
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
            return nil
        }

        if let account = result?[kSecAttrAccount] as? String,
           let data = result?[kSecValueData] as? Data,
           let password = String(data: data, encoding: .utf8)
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
            return
        }
    }
}
