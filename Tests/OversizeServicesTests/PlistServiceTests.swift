//
// Copyright © 2026 Alexander Romanov
// PlistServiceTests.swift
//

import Foundation
@testable import OversizeServices
import Testing

struct PlistServiceTests {
    private let missingPlist = "MissingPlistThatDoesNotExist"
    private let service = PlistService()

    @Test
    func stringArrayIsEmptyForMissingPlist() {
        let value = service.getStringArrayFromDictionary(field: "Field", dictionary: "Links", plist: missingPlist)

        #expect(value.isEmpty)
    }

    @Test
    func boolIsNilForMissingPlist() {
        #expect(service.getBoolFromDictionary(field: "Field", dictionary: "Links", plist: missingPlist) == nil)
    }

    @Test
    func intIsNilForMissingPlist() {
        #expect(service.getIntFromDictionary(field: "Field", dictionary: "Links", plist: missingPlist) == nil)
    }

    @Test
    func stringIsNilForMissingPlist() {
        #expect(service.getStringFromDictionary(field: "Field", dictionary: "Links", plist: missingPlist) == nil)
        #expect(service.getString(field: "Field", plist: missingPlist) == nil)
    }

    @Test
    func sharedInstanceIsReused() {
        #expect(PlistService.shared === PlistService.shared)
    }
}
