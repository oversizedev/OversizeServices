//
// Copyright © 2026 Alexander Romanov
// MockFileManagerService.swift
//

import Foundation
import OversizeCore
import OversizeFileManagerService

final class MockFileManagerService: FileManagerServiceProtocol {
    var saveDocumentResult: Result<URL, Error> = .failure(FileError.saveFailed)
    var removeDocumentResult: Result<Bool, Error> = .failure(FileError.deleteFailed)
    var removeFolderResult: Result<Bool, Error> = .failure(FileError.deleteFailed)
    var giveURLResult: URL?

    private(set) var saveDocumentCalls: [(pickedURL: URL, folder: String?)] = []
    private(set) var removeDocumentCalls: [URL] = []
    private(set) var removeFolderCalls: [String] = []
    private(set) var giveURLCalls: [(folder: String?, file: String)] = []

    func saveDocument(pickedURL: URL, folder: String?) async -> Result<URL, Error> {
        saveDocumentCalls.append((pickedURL, folder))
        return saveDocumentResult
    }

    func removeDocument(localURL: URL) async -> Result<Bool, Error> {
        removeDocumentCalls.append(localURL)
        return removeDocumentResult
    }

    func removeFolder(_ folder: String) async -> Result<Bool, Error> {
        removeFolderCalls.append(folder)
        return removeFolderResult
    }

    func giveURL(folder: String?, file: String) async -> URL? {
        giveURLCalls.append((folder, file))
        return giveURLResult
    }
}
