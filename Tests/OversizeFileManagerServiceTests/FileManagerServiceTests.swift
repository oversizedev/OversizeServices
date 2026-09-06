//
// Copyright © 2026 Alexander Romanov
// FileManagerServiceTests.swift
//

import Foundation
import OversizeCore
@testable import OversizeFileManagerService
import Testing

final class FileManagerServiceTests {
    private let service = FileManagerService()
    private let folder = "OversizeServicesTests-\(UUID().uuidString)"
    private let documentsURL: URL?

    init() {
        documentsURL = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true,
        )
    }

    deinit {
        guard let folderURL = documentsURL?.appendingPathComponent(folder, isDirectory: true) else { return }
        try? FileManager.default.removeItem(at: folderURL)
    }

    @Test
    func giveURLAppendsFileToDocumentsRoot() async throws {
        let root = try #require(documentsURL)

        let url = await service.giveURL(folder: nil, file: "document.pdf")

        #expect(url == root.appendingPathComponent("document.pdf", isDirectory: false))
    }

    @Test
    func giveURLAppendsFolderAndFile() async throws {
        let root = try #require(documentsURL)

        let url = await service.giveURL(folder: folder, file: "document.pdf")

        let expected = root
            .appendingPathComponent(folder, isDirectory: true)
            .appendingPathComponent("document.pdf", isDirectory: false)
        #expect(url == expected)
    }

    @Test
    func removeFolderDeletesExistingFolder() async throws {
        let root = try #require(documentsURL)
        let folderURL = root.appendingPathComponent(folder, isDirectory: true)
        try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)

        let result = await service.removeFolder(folder)

        #expect(expectSuccess(result) == true)
        #expect(FileManager.default.fileExists(atPath: folderURL.path) == false)
    }

    @Test
    func removeFolderFailsForMissingFolder() async {
        let result = await service.removeFolder(folder)

        expectFailure(result, is: FileError.deleteFailed)
    }

    @Test
    func removeDocumentDeletesExistingFile() async throws {
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("\(UUID().uuidString).txt")
        try Data("content".utf8).write(to: fileURL)

        let result = await service.removeDocument(localURL: fileURL)

        #expect(expectSuccess(result) == true)
        #expect(FileManager.default.fileExists(atPath: fileURL.path) == false)
    }

    @Test
    func removeDocumentFailsForMissingFile() async {
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("\(UUID().uuidString).txt")

        let result = await service.removeDocument(localURL: fileURL)

        expectFailure(result, is: FileError.deleteFailed)
    }
}
