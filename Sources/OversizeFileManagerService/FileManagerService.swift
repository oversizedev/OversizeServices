//
// Copyright © 2022 Alexander Romanov
// FileManagerService.swift
//

import Foundation
import OversizeCore

public protocol FileManagerServiceProtocol {
    func saveDocument(pickedURL: URL, folder: String?) async -> Result<URL, Error>
    func removeDocument(localURL: URL) async -> Result<Bool, Error>
    func removeFolder(_ folder: String) async -> Result<Bool, Error>
    func giveURL(folder: String?, file: String) async -> URL?
}

public final class FileManagerService: FileManagerServiceProtocol {
    private let rootUrl: URL?

    public init() {
        do {
            rootUrl = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        } catch {
            rootUrl = nil
        }
    }

    /// Copy the document at pickedURL to localURL
    /// - Parameters:
    ///   - pickedURL: URL of picked document
    ///   - project: project name
    /// - Returns: Local URL of document
    public func saveDocument(pickedURL: URL, folder: String?) async -> Result<URL, Error> {
        guard let url = rootUrl else {
            return .failure(FileError.accessDenied)
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
                    return .failure(FileError.saveFailed)
                }
            }

            var isDir: ObjCBool = false
            if FileManager.default.fileExists(atPath: destinationDocumentsURL.path, isDirectory: &isDir) {
                try FileManager.default.removeItem(at: destinationDocumentsURL)
            }
            guard pickedURL.startAccessingSecurityScopedResource() else {
                return .failure(FileError.saveFailed)
            }

            defer {
                pickedURL.stopAccessingSecurityScopedResource()
            }
            try FileManager.default.copyItem(at: pickedURL, to: destinationDocumentsURL)
            return .success(destinationDocumentsURL)
        } catch {
            return .failure(FileError.saveFailed)
        }
    }

    /// Remove Document at URL
    /// - Parameter localURL: URL of Document to be removed
    public func removeDocument(localURL: URL) async -> Result<Bool, Error> {
        do {
            try FileManager.default.removeItem(at: localURL)
            return .success(true)
        } catch {
            return .failure(FileError.deleteFailed)
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
    public func removeFolder(_ folder: String) async -> Result<Bool, Error> {
        guard let url = rootUrl else {
            return .failure(FileError.deleteFailed)
        }
        let localDocumentsURL = url
            .appendingPathComponent(folder, isDirectory: true)
        var isDir: ObjCBool = true

        if FileManager.default.fileExists(atPath: localDocumentsURL.path, isDirectory: &isDir) {
            do {
                try FileManager.default.removeItem(at: localDocumentsURL)
                return .success(true)
            } catch {
                return .failure(FileError.deleteFailed)
            }
        }
        return .failure(FileError.deleteFailed)
    }
}
