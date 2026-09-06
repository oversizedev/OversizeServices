//
// Copyright © 2026 Alexander Romanov
// MockCloudDocumentsService.swift
//

import Foundation
import OversizeCore
import OversizeFileManagerService

final class MockCloudDocumentsService: CloudDocumentsServiceProtocol {
    var saveDocumentResult: Result<URL, Error> = .failure(CloudError.saveFailed)
    var removeDocumentResult: Result<Bool, Error> = .failure(CloudError.deleteFailed)
    var removeFolderResult: Result<Bool, Error> = .failure(CloudError.deleteFailed)
    var giveURLResult: URL?

    private(set) var saveDocumentCalls: [(localDocumentsURL: URL, folder: String?, containerId: String?)] = []
    private(set) var removeDocumentCalls: [URL] = []
    private(set) var removeFolderCalls: [(folder: String, containerId: String?)] = []
    private(set) var giveURLCalls: [(folder: String?, file: String, containerId: String?)] = []

    func saveDocument(localDocumentsURL: URL, folder: String?, containerId: String?) async -> Result<URL, Error> {
        saveDocumentCalls.append((localDocumentsURL, folder, containerId))
        return saveDocumentResult
    }

    func removeDocument(icloudUrl: URL) async -> Result<Bool, Error> {
        removeDocumentCalls.append(icloudUrl)
        return removeDocumentResult
    }

    func removeFolder(_ folder: String, containerId: String?) async -> Result<Bool, Error> {
        removeFolderCalls.append((folder, containerId))
        return removeFolderResult
    }

    func giveURL(folder: String?, file: String, containerId: String?) async -> URL? {
        giveURLCalls.append((folder, file, containerId))
        return giveURLResult
    }
}
