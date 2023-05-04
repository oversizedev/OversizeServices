//
// Copyright © 2022 Alexander Romanov
// FileManagerService.swift
//

import Foundation
import OversizeCore
import OversizeServices

public protocol FileManagerServiceProtocol {
    func saveDocument(pickedURL: URL, folder: String?) async -> Result<URL, AppError>
    func removeDocument(localURL: URL) async -> Result<Bool, AppError>
    func removeFolder(_ folder: String) async -> Result<Bool, AppError>
    func giveURL(folder: String?, file: String) async -> URL?
}

public final class FileManagerService: FileManagerServiceProtocol {
    private let rootUrl: URL?

    public init() {
        do {
            rootUrl = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            log(rootUrl)
        } catch {
            rootUrl = nil
            log(error)
        }
    }

    /// Copy the document at pickedURL to localURL
    /// - Parameters:
    ///   - pickedURL: URL of picked document
    ///   - project: project name
    /// - Returns: Local URL of document
    public func saveDocument(pickedURL: URL, folder: String?) async -> Result<URL, AppError> {
        guard let url = rootUrl else {
            return .failure(.fileManager(type: .notAccess))
        }
        do {
            var destinationDocumentsURL: URL = url

            if let folder {
                destinationDocumentsURL = destinationDocumentsURL
                    .appendingPathComponent(folder, isDirectory: true)
                    .appendingPathComponent(pickedURL.lastPathComponent)
            } else {
                destinationDocumentsURL = destinationDocumentsURL
                    .appendingPathComponent(pickedURL.lastPathComponent)
            }

            if !FileManager.default.fileExists(atPath: destinationDocumentsURL.path, isDirectory: nil) {
                do {
                    try FileManager.default.createDirectory(at: destinationDocumentsURL, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    return .failure(.fileManager(type: .savingItem))
                }
            }

            var isDir: ObjCBool = false
            if FileManager.default.fileExists(atPath: destinationDocumentsURL.path, isDirectory: &isDir) {
                try FileManager.default.removeItem(at: destinationDocumentsURL)
            }
            guard pickedURL.startAccessingSecurityScopedResource() else {
                return .failure(.fileManager(type: .savingItem))
            }

            defer {
                pickedURL.stopAccessingSecurityScopedResource()
            }
            try FileManager.default.copyItem(at: pickedURL, to: destinationDocumentsURL)
            return .success(destinationDocumentsURL)
        } catch {
            return .failure(.fileManager(type: .savingItem))
        }
    }

    /// Remove Document at URL
    /// - Parameter localURL: URL of Document to be removed
    public func removeDocument(localURL: URL) async -> Result<Bool, AppError> {
        do {
            try FileManager.default.removeItem(at: localURL)
            return .success(true)
        } catch {
            return .failure(.fileManager(type: .deleteItem))
        }
    }

    /// Return the URL of a document
    /// - Parameters:
    ///   - project: name of project
    ///   - file: name of file
    /// - Returns: URL of file
    public func giveURL(folder: String?, file: String) async -> URL? {
        if let folder {
            guard var iCloudDocumentsURL =
                rootUrl?.appendingPathComponent(folder, isDirectory: true)
            else {
                return nil
            }
            iCloudDocumentsURL = iCloudDocumentsURL.appendingPathComponent(file, isDirectory: false)
            return iCloudDocumentsURL
        } else {
            guard var iCloudDocumentsURL = rootUrl else {
                return nil
            }
            iCloudDocumentsURL = iCloudDocumentsURL.appendingPathComponent(file, isDirectory: false)
            return iCloudDocumentsURL
        }
    }

    /// Remove Project Directory
    /// - Parameter project: project name
    public func removeFolder(_ folder: String) async -> Result<Bool, AppError> {
        guard let url = rootUrl else {
            return .failure(.fileManager(type: .deleteItem))
        }
        let localDocumentsURL = url
            .appendingPathComponent(folder, isDirectory: true)
        var isDir: ObjCBool = true

        if FileManager.default.fileExists(atPath: localDocumentsURL.path, isDirectory: &isDir) {
            do {
                try FileManager.default.removeItem(at: localDocumentsURL)
                return .success(true)
            } catch {
                return .failure(.fileManager(type: .deleteItem))
            }
        }
        return .failure(.fileManager(type: .deleteItem))
    }
}
