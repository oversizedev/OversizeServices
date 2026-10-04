//
// Copyright © 2026 Alexander Romanov
// Keychain.swift, created on 04.10.2026
//

import Foundation
import Security

public struct Keychain: Sendable {
    public enum Accessibility: Sendable {
        case afterFirstUnlock
        case afterFirstUnlockThisDeviceOnly
        case whenUnlocked
        case whenUnlockedThisDeviceOnly
        case whenPasscodeSetThisDeviceOnly
    }

    public let service: String?
    public let accessibility: Accessibility
    public let synchronizable: Bool
    public let useDataProtectionKeychain: Bool

    public init(
        service: String?,
        accessibility: Accessibility = .afterFirstUnlock,
        synchronizable: Bool = false,
        useDataProtectionKeychain: Bool = false,
    ) {
        precondition(
            !synchronizable || accessibility.supportsSynchronization,
            "A ThisDeviceOnly accessibility cannot be combined with synchronizable",
        )
        self.service = service
        self.accessibility = accessibility
        self.synchronizable = synchronizable
        self.useDataProtectionKeychain = useDataProtectionKeychain
    }

    public func data(forKey key: String) throws -> Data? {
        var query = query(forKey: key)
        query[kSecReturnData] = kCFBooleanTrue
        query[kSecMatchLimit] = kSecMatchLimitOne
        return try copy(query)
    }

    public func string(forKey key: String) throws -> String? {
        guard let data = try data(forKey: key) else { return nil }
        guard let string = String(data: data, encoding: .utf8) else { throw KeychainError.decodingFailed }
        return string
    }

    public func object<Value: Decodable>(_ type: Value.Type = Value.self, forKey key: String) throws -> Value? {
        guard let data = try data(forKey: key) else { return nil }
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw KeychainError.decodingFailed
        }
    }

    public func set(_ data: Data, forKey key: String) throws {
        let query = query(forKey: key)
        var attributes = query
        attributes[kSecValueData] = data
        if enforcesAccessibility {
            attributes[kSecAttrAccessible] = accessibility.attribute
        }
        let addStatus = SecItemAdd(attributes as CFDictionary, nil)
        guard addStatus == errSecDuplicateItem else { return try check(addStatus) }
        var changes: [CFString: Any] = [kSecValueData: data]
        if enforcesAccessibility {
            changes[kSecAttrAccessible] = accessibility.attribute
        }
        let updateStatus = SecItemUpdate(query as CFDictionary, changes as CFDictionary)
        guard updateStatus == errSecItemNotFound else { return try check(updateStatus) }
        try check(SecItemAdd(attributes as CFDictionary, nil))
    }

    public func set(_ string: String, forKey key: String) throws {
        try set(Data(string.utf8), forKey: key)
    }

    public func setObject(_ object: some Encodable, forKey key: String) throws {
        let data: Data
        do {
            data = try JSONEncoder().encode(object)
        } catch {
            throw KeychainError.encodingFailed
        }
        try set(data, forKey: key)
    }

    public func hasItem(forKey key: String) throws -> Bool {
        var query = query(forKey: key)
        query[kSecMatchLimit] = kSecMatchLimitOne
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        guard status != errSecItemNotFound else { return false }
        try check(status)
        return true
    }

    public func keys() throws -> [String] {
        guard service != nil else { throw KeychainError.serviceRequired }
        var query = baseQuery()
        query[kSecReturnAttributes] = kCFBooleanTrue
        query[kSecMatchLimit] = kSecMatchLimitAll
        let items: [[CFString: Any]] = try copy(query) ?? []
        return items.compactMap { $0[kSecAttrAccount] as? String }
    }

    public func remove(forKey key: String) throws {
        try delete(query(forKey: key))
    }

    public func removeAll() throws {
        guard service != nil else { throw KeychainError.serviceRequired }
        var query = baseQuery()
        #if os(macOS)
        if !usesDataProtectionKeychain {
            query[kSecMatchLimit] = kSecMatchLimitAll
        }
        #endif
        try delete(query)
    }
}

extension Keychain {
    func baseQuery() -> [CFString: Any] {
        var query: [CFString: Any] = [kSecClass: kSecClassGenericPassword]
        if let service {
            query[kSecAttrService] = service
        }
        if synchronizable {
            query[kSecAttrSynchronizable] = kCFBooleanTrue
        }
        if useDataProtectionKeychain {
            query[kSecUseDataProtectionKeychain] = kCFBooleanTrue
        }
        return query
    }

    func query(forKey key: String) -> [CFString: Any] {
        var query = baseQuery()
        query[kSecAttrAccount] = key
        return query
    }
}

private extension Keychain {
    var usesDataProtectionKeychain: Bool {
        useDataProtectionKeychain || synchronizable
    }

    var enforcesAccessibility: Bool {
        #if os(macOS)
        usesDataProtectionKeychain
        #else
        true
        #endif
    }

    func copy<Result>(_ query: [CFString: Any]) throws -> Result? {
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status != errSecItemNotFound else { return nil }
        try check(status)
        guard let result = result as? Result else { throw KeychainError.decodingFailed }
        return result
    }

    func delete(_ query: [CFString: Any]) throws {
        let status = SecItemDelete(query as CFDictionary)
        guard status != errSecItemNotFound else { return }
        try check(status)
    }

    func check(_ status: OSStatus) throws {
        guard status == errSecSuccess else { throw KeychainError.unavailable(status) }
    }
}

private extension Keychain.Accessibility {
    var supportsSynchronization: Bool {
        switch self {
        case .afterFirstUnlock, .whenUnlocked: true
        case .afterFirstUnlockThisDeviceOnly, .whenUnlockedThisDeviceOnly, .whenPasscodeSetThisDeviceOnly: false
        }
    }

    var attribute: CFString {
        switch self {
        case .afterFirstUnlock: kSecAttrAccessibleAfterFirstUnlock
        case .afterFirstUnlockThisDeviceOnly: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        case .whenUnlocked: kSecAttrAccessibleWhenUnlocked
        case .whenUnlockedThisDeviceOnly: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        case .whenPasscodeSetThisDeviceOnly: kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        }
    }
}
