//
// Copyright © 2026 Alexander Romanov
// FileManagerSyncServiceTests.swift
//

import FactoryKit
import FactoryTesting
import Foundation
import OversizeCore
@testable import OversizeFileManagerService
import Testing

struct FileManagerSyncServiceTests {
    private static var isICloudAvailable: Bool {
        FileManager.default.ubiquityIdentityToken != nil
    }

    private func makeTemporaryFile() throws -> URL {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("\(UUID().uuidString).txt")
        try Data("content".utf8).write(to: url)
        return url
    }

    @Test(.container)
    func saveDocumentLocallyRoutesToFileManagerService() async {
        let fileManagerService = MockFileManagerService()
        let cloudDocumentsService = MockCloudDocumentsService()
        let destination = URL(fileURLWithPath: "/tmp/destination.txt")
        fileManagerService.saveDocumentResult = .success(destination)
        Container.shared.fileManagerService.register { fileManagerService }
        Container.shared.cloudDocumentsService.register { cloudDocumentsService }

        let service = FileManagerSyncService()
        let source = URL(fileURLWithPath: "/tmp/source.txt")
        let result = await service.saveDocument(fileURL: source, folder: "Documents", location: .local)

        #expect(expectSuccess(result) == destination)
        #expect(fileManagerService.saveDocumentCalls.count == 1)
        #expect(fileManagerService.saveDocumentCalls.first?.pickedURL == source)
        #expect(fileManagerService.saveDocumentCalls.first?.folder == "Documents")
        #expect(cloudDocumentsService.saveDocumentCalls.isEmpty)
    }

    @Test(.container)
    func saveDocumentLocallyPropagatesFailure() async {
        let fileManagerService = MockFileManagerService()
        fileManagerService.saveDocumentResult = .failure(FileError.saveFailed)
        Container.shared.fileManagerService.register { fileManagerService }
        Container.shared.cloudDocumentsService.register { MockCloudDocumentsService() }

        let service = FileManagerSyncService()
        let result = await service.saveDocument(
            fileURL: URL(fileURLWithPath: "/tmp/source.txt"),
            folder: nil,
            location: .local,
        )

        expectFailure(result, is: FileError.saveFailed)
    }

    @Test(.container, .enabled(if: !FileManagerSyncServiceTests.isICloudAvailable))
    func saveDocumentToICloudFailsWithoutAccount() async {
        let cloudDocumentsService = MockCloudDocumentsService()
        Container.shared.fileManagerService.register { MockFileManagerService() }
        Container.shared.cloudDocumentsService.register { cloudDocumentsService }

        let service = FileManagerSyncService()
        let result = await service.saveDocument(
            fileURL: URL(fileURLWithPath: "/tmp/source.txt"),
            folder: nil,
            location: .iCloud,
        )

        expectFailure(result, is: CloudError.noAccount)
        #expect(cloudDocumentsService.saveDocumentCalls.isEmpty)
    }

    @Test(.container, .enabled(if: FileManagerSyncServiceTests.isICloudAvailable))
    func saveDocumentToICloudRoutesToCloudService() async {
        let cloudDocumentsService = MockCloudDocumentsService()
        let destination = URL(fileURLWithPath: "/tmp/cloud.txt")
        cloudDocumentsService.saveDocumentResult = .success(destination)
        Container.shared.fileManagerService.register { MockFileManagerService() }
        Container.shared.cloudDocumentsService.register { cloudDocumentsService }

        let service = FileManagerSyncService()
        let source = URL(fileURLWithPath: "/tmp/source.txt")
        let result = await service.saveDocument(fileURL: source, folder: "Documents", location: .iCloud)

        #expect(expectSuccess(result) == destination)
        #expect(cloudDocumentsService.saveDocumentCalls.count == 1)
        #expect(cloudDocumentsService.saveDocumentCalls.first?.containerId == nil)
    }

    @Test(.container)
    func generateUrlReturnsExistingUrlWithoutTouchingServices() async throws {
        let fileManagerService = MockFileManagerService()
        let cloudDocumentsService = MockCloudDocumentsService()
        Container.shared.fileManagerService.register { fileManagerService }
        Container.shared.cloudDocumentsService.register { cloudDocumentsService }
        let existing = try makeTemporaryFile()
        defer { try? FileManager.default.removeItem(at: existing) }

        let service = FileManagerSyncService()
        let result = await service.generateUrl(
            urlString: existing.absoluteString,
            location: .local,
            folder: nil,
            file: nil,
        )

        #expect(expectSuccess(result) == existing)
        #expect(fileManagerService.giveURLCalls.isEmpty)
        #expect(cloudDocumentsService.giveURLCalls.isEmpty)
    }

    @Test(.container)
    func generateUrlLocallyReturnsUrlFromFileManagerService() async throws {
        let fileManagerService = MockFileManagerService()
        let existing = try makeTemporaryFile()
        defer { try? FileManager.default.removeItem(at: existing) }
        fileManagerService.giveURLResult = existing
        Container.shared.fileManagerService.register { fileManagerService }
        Container.shared.cloudDocumentsService.register { MockCloudDocumentsService() }

        let service = FileManagerSyncService()
        let result = await service.generateUrl(urlString: nil, location: .local, folder: "Docs", file: "a.txt")

        #expect(expectSuccess(result) == existing)
        #expect(fileManagerService.giveURLCalls.first?.folder == "Docs")
        #expect(fileManagerService.giveURLCalls.first?.file == "a.txt")
    }

    @Test(.container)
    func generateUrlLocallyFailsWhenFileIsMissing() async {
        let fileManagerService = MockFileManagerService()
        fileManagerService.giveURLResult = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("\(UUID().uuidString).txt")
        Container.shared.fileManagerService.register { fileManagerService }
        Container.shared.cloudDocumentsService.register { MockCloudDocumentsService() }

        let service = FileManagerSyncService()
        let result = await service.generateUrl(urlString: nil, location: .local, folder: nil, file: nil)

        expectFailure(result, is: FileError.fetchFailed)
    }

    @Test(.container)
    func generateUrlUsesDefaultFileNameWhenMissing() async {
        let fileManagerService = MockFileManagerService()
        Container.shared.fileManagerService.register { fileManagerService }
        Container.shared.cloudDocumentsService.register { MockCloudDocumentsService() }

        let service = FileManagerSyncService()
        _ = await service.generateUrl(urlString: nil, location: .local, folder: nil, file: nil)

        #expect(fileManagerService.giveURLCalls.first?.file == "file")
    }

    @Test(.container)
    func generateUrlInICloudFailsWhenCloudServiceReturnsNothing() async {
        let cloudDocumentsService = MockCloudDocumentsService()
        Container.shared.fileManagerService.register { MockFileManagerService() }
        Container.shared.cloudDocumentsService.register { cloudDocumentsService }

        let service = FileManagerSyncService()
        let result = await service.generateUrl(urlString: nil, location: .iCloud, folder: "Docs", file: "a.txt")

        expectFailure(result, is: CloudError.fetchFailed)
        #expect(cloudDocumentsService.giveURLCalls.count == 1)
    }

    @Test(.container)
    func deleteDocumentFailsWhenUrlCannotBeResolved() async {
        Container.shared.fileManagerService.register { MockFileManagerService() }
        Container.shared.cloudDocumentsService.register { MockCloudDocumentsService() }

        let service = FileManagerSyncService()
        let result = await service.deleteDocument(urlString: nil, location: .local, folder: nil, file: nil)

        expectFailure(result, is: FileError.fetchFailed)
    }

    @Test(.container, .enabled(if: !FileManagerSyncServiceTests.isICloudAvailable))
    func deleteDocumentRoutesToCloudServiceWithoutICloudAccount() async throws {
        let fileManagerService = MockFileManagerService()
        let cloudDocumentsService = MockCloudDocumentsService()
        let existing = try makeTemporaryFile()
        defer { try? FileManager.default.removeItem(at: existing) }
        fileManagerService.giveURLResult = existing
        cloudDocumentsService.removeDocumentResult = .success(true)
        Container.shared.fileManagerService.register { fileManagerService }
        Container.shared.cloudDocumentsService.register { cloudDocumentsService }

        let service = FileManagerSyncService()
        let result = await service.deleteDocument(urlString: nil, location: .local, folder: nil, file: "a.txt")

        #expect(expectSuccess(result) == true)
        #expect(cloudDocumentsService.removeDocumentCalls == [existing])
        #expect(fileManagerService.removeDocumentCalls.isEmpty)
    }

    @Test(.container, .enabled(if: FileManagerSyncServiceTests.isICloudAvailable))
    func deleteDocumentRoutesToFileManagerServiceWithICloudAccount() async throws {
        let fileManagerService = MockFileManagerService()
        let cloudDocumentsService = MockCloudDocumentsService()
        let existing = try makeTemporaryFile()
        defer { try? FileManager.default.removeItem(at: existing) }
        fileManagerService.giveURLResult = existing
        fileManagerService.removeDocumentResult = .success(true)
        Container.shared.fileManagerService.register { fileManagerService }
        Container.shared.cloudDocumentsService.register { cloudDocumentsService }

        let service = FileManagerSyncService()
        let result = await service.deleteDocument(urlString: nil, location: .local, folder: nil, file: "a.txt")

        #expect(expectSuccess(result) == true)
        #expect(fileManagerService.removeDocumentCalls == [existing])
        #expect(cloudDocumentsService.removeDocumentCalls.isEmpty)
    }

    @Test(.container)
    func isICloudContainerAvailableMatchesUbiquityToken() {
        let service = FileManagerSyncService()

        let result = service.isICloudContainerAvailable()

        if Self.isICloudAvailable {
            #expect(expectSuccess(result) == true)
        } else {
            expectFailure(result, is: CloudError.noAccount)
        }
    }
}
