//
// Copyright © 2026 Alexander Romanov
// KeychainTests.swift, created on 04.10.2026
//

import Foundation
@testable import OversizeServices
import Testing

struct KeychainTests {
    private struct Credentials: Codable, Equatable {
        let login: String
        let token: String
    }

    private let service = "Tests.OversizeServices.Keychain." + UUID().uuidString
    private let otherService = "Tests.OversizeServices.Keychain.Other." + UUID().uuidString
    private let legacyKey = "Tests.OversizeServices.Keychain.Legacy." + UUID().uuidString

    private var keychain: Keychain { Keychain(service: service) }
    private var otherKeychain: Keychain { Keychain(service: otherService) }
    private var legacyKeychain: Keychain { Keychain(service: nil) }

    private func cleanUp() {
        try? keychain.removeAll()
        try? otherKeychain.removeAll()
        try? legacyKeychain.remove(forKey: legacyKey)
    }

    @Test
    func missingItemIsNil() throws {
        defer { cleanUp() }

        #expect(try keychain.string(forKey: "missing") == nil)
        #expect(try keychain.data(forKey: "missing") == nil)
        #expect(try keychain.object(Credentials.self, forKey: "missing") == nil)
        #expect(try keychain.hasItem(forKey: "missing") == false)
    }

    @Test
    func stringRoundTrip() throws {
        defer { cleanUp() }

        try keychain.set("first", forKey: "token")
        try keychain.set("second", forKey: "token")

        #expect(try keychain.string(forKey: "token") == "second")
        #expect(try keychain.data(forKey: "token") == Data("second".utf8))
        #expect(try keychain.hasItem(forKey: "token"))
    }

    @Test
    func dataRoundTrip() throws {
        defer { cleanUp() }
        let blob = Data([0x00, 0xFF, 0x10])

        try keychain.set(blob, forKey: "blob")

        #expect(try keychain.data(forKey: "blob") == blob)
    }

    @Test
    func codableRoundTrip() throws {
        defer { cleanUp() }
        let credentials = Credentials(login: "user", token: "secret")

        try keychain.setObject(credentials, forKey: "credentials")

        #expect(try keychain.object(forKey: "credentials") == credentials)
    }

    @Test
    func stringAndObjectUseDifferentEncodings() throws {
        defer { cleanUp() }

        try keychain.set("abc", forKey: "plain")
        try keychain.setObject("abc", forKey: "encoded")

        #expect(throws: KeychainError.decodingFailed) {
            try keychain.object(String.self, forKey: "plain")
        }
        #expect(try keychain.object(String.self, forKey: "encoded") == "abc")
        #expect(try keychain.string(forKey: "encoded") == "\"abc\"")
    }

    @Test
    func undecodableItemThrows() throws {
        defer { cleanUp() }
        try keychain.set(Data("not json".utf8), forKey: "broken")

        #expect(throws: KeychainError.decodingFailed) {
            try keychain.object(Credentials.self, forKey: "broken")
        }
    }

    @Test
    func removingMissingItemDoesNotThrow() throws {
        defer { cleanUp() }

        try keychain.remove(forKey: "absent")

        #expect(try keychain.string(forKey: "absent") == nil)
    }

    @Test
    func removeKeepsTheSameKeyOfOtherServices() throws {
        defer { cleanUp() }
        try keychain.set("mine", forKey: "shared")
        try otherKeychain.set("theirs", forKey: "shared")

        try keychain.remove(forKey: "shared")

        #expect(try keychain.string(forKey: "shared") == nil)
        #expect(try otherKeychain.string(forKey: "shared") == "theirs")
    }

    @Test
    func removeAllKeepsOtherServices() throws {
        defer { cleanUp() }
        try keychain.set("1", forKey: "one")
        try keychain.set("2", forKey: "two")
        try otherKeychain.set("3", forKey: "one")

        try keychain.removeAll()

        #expect(try keychain.string(forKey: "one") == nil)
        #expect(try keychain.string(forKey: "two") == nil)
        #expect(try otherKeychain.string(forKey: "one") == "3")
    }

    @Test
    func serviceLessRoundTrip() throws {
        defer { cleanUp() }
        #expect(try legacyKeychain.string(forKey: legacyKey) == nil)

        try legacyKeychain.set("first", forKey: legacyKey)
        try legacyKeychain.set("second", forKey: legacyKey)
        #expect(try legacyKeychain.string(forKey: legacyKey) == "second")

        try legacyKeychain.remove(forKey: legacyKey)
        #expect(try legacyKeychain.string(forKey: legacyKey) == nil)
    }

    @Test
    func serviceLessItemIsInvisibleToNamedServices() throws {
        defer { cleanUp() }
        try legacyKeychain.set("legacy", forKey: legacyKey)

        #expect(try keychain.string(forKey: legacyKey) == nil)
        #expect(try keychain.hasItem(forKey: legacyKey) == false)
    }

    @Test
    func removeAllNeedsAService() {
        #expect(throws: KeychainError.serviceRequired) {
            try legacyKeychain.removeAll()
        }
    }
}
