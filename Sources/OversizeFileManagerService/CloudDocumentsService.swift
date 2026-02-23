//
// Copyright © 2022 Alexander Romanov
// CloudDocumentsService.swift
//

import Foundation
import OversizeCore

public protocol CloudDocumentsServiceProtocol {
    func saveDocument(localDocumentsURL: URL, folder: String?, containerId: String?) async -> Result<URL, Error>
    func removeDocument(icloudUrl: URL) async -> Result<Bool, Error>
    func removeFolder(_ folder: String, containerId: String?) async -> Result<Bool, Error>
    func giveURL(folder: String?, file: String, containerId: String?) async -> URL?
}

public final class CloudDocumentsService: CloudDocumentsServiceProtocol {
    public func saveDocument(localDocumentsURL: URL, folder: String?, containerId: String? = nil) async -> Result<URL, Error> {
        if let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: containerId)?.appendingPathComponent("Documents", isDirectory: true) {
            if !FileManager.default.fileExists(atPath: iCloudDocumentsURL.path, isDirectory: nil) {
                do {
                    try FileManager.default.createDirectory(at: iCloudDocumentsURL, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    return .failure(CloudError.saveFailed)
                }
            }
        }

        var iCloudDocumentsURL: URL?

        if let folder {
            if let iCloudDocumentsFolderURL = FileManager.default.url(forUbiquityContainerIdentifier: containerId)?
                .appendingPathComponent("Documents", isDirectory: true)
                .appendingPathComponent(folder, isDirectory: true)
            {
                if !FileManager.default.fileExists(atPath: iCloudDocumentsFolderURL.path, isDirectory: nil) {
                    do {
                        try FileManager.default.createDirectory(at: iCloudDocumentsFolderURL, withIntermediateDirectories: true, attributes: nil)
                    } catch {
                        return .failure(CloudError.saveFailed)
                    }
                }
            }

            iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: containerId)?
                .appendingPathComponent("Documents", isDirectory: true)
                .appendingPathComponent(folder, isDirectory: true)
        } else {
            iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: containerId)?
                .appendingPathComponent("Documents", isDirectory: true)
        }

        iCloudDocumentsURL = iCloudDocumentsURL?.appendingPathComponent(localDocumentsURL.lastPathComponent, isDirectory: false)
        var isDir: ObjCBool = false

        guard let iCloudDocumentsURL else {
            return .failure(CloudError.accessDenied)
        }

        if FileManager.default.fileExists(atPath: iCloudDocumentsURL.path, isDirectory: &isDir) {
            do {
                try FileManager.default.removeItem(at: iCloudDocumentsURL)
            } catch {
                return .failure(CloudError.saveFailed)
            }
        }

        do {
            guard localDocumentsURL.startAccessingSecurityScopedResource() else { return .failure(CloudError.accessDenied) }
            defer {
                localDocumentsURL.stopAccessingSecurityScopedResource()
            }

            try FileManager.default.copyItem(at: localDocumentsURL, to: iCloudDocumentsURL)
            return .success(iCloudDocumentsURL)
        } catch {
            return .failure(CloudError.saveFailed)
        }
    }

    public func removeDocument(icloudUrl: URL) async -> Result<Bool, Error> {
        do {
            try FileManager.default.removeItem(at: icloudUrl)
            return .success(true)
        } catch {
            return .failure(CloudError.deleteFailed)
        }
    }

    public func removeFolder(_ folder: String, containerId: String? = nil) async -> Result<Bool, Error> {
        guard let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: containerId)?
            .appendingPathComponent("Documents", isDirectory: true)
            .appendingPathComponent(folder, isDirectory: true)
        else { return .failure(CloudError.deleteFailed) }
        var isDir: ObjCBool = true

        if FileManager.default.fileExists(atPath: iCloudDocumentsURL.path, isDirectory: &isDir) {
            do {
                try FileManager.default.removeItem(at: iCloudDocumentsURL)
                return .success(true)
            } catch {
                return .failure(CloudError.deleteFailed)
            }
        }
        return .failure(CloudError.deleteFailed)
    }

    public func giveURL(folder: String?, file: String, containerId: String? = nil) -> URL? {
        if let folder {
            guard var iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: containerId)?
                .appendingPathComponent("Documents", isDirectory: true)
                .appendingPathComponent(folder, isDirectory: true)
            else {
                return nil
            }
            iCloudDocumentsURL = iCloudDocumentsURL.appendingPathComponent(file, isDirectory: false)
            return iCloudDocumentsURL
        } else {
            guard var iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: containerId)?
                .appendingPathComponent("Documents", isDirectory: true)
            else {
                return nil
            }
            iCloudDocumentsURL = iCloudDocumentsURL.appendingPathComponent(file, isDirectory: false)
            return iCloudDocumentsURL
        }
    }
}
