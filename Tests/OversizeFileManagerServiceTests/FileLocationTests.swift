//
// Copyright © 2026 Alexander Romanov
// FileLocationTests.swift
//

@testable import OversizeFileManagerService
import Testing

struct FileLocationTests {
    @Test
    func rawValues() {
        #expect(FileLocation.iCloud.rawValue == "iCloud")
        #expect(FileLocation.local.rawValue == "local")
        #expect(FileLocation(rawValue: "iCloud") == .iCloud)
        #expect(FileLocation(rawValue: "unknown") == nil)
    }
}
