//
// Copyright © 2023 Alexander Romanov
// FileManagerSync.swift, created on 01.05.2023
//

import FactoryKit
import Foundation
import OversizeCore

public protocol FileManagerSyncServiceProtocol {
    func isICloudContainerAvailable() -> Result<Bool, Error>
    func generateUrl(urlString: String?, location: FileLocation, folder: String?, file: String?) async -> Result<URL, Error>
    func deleteDocument(urlString: String?, location: FileLocation, folder: String?, file: String?) async -> Result<Bool, Error>
    func saveDocument(fileURL: URL, folder: String?, location: FileLocation) async -> Result<URL, Error>
}

public class FileManagerSyncService {
    @Injected(\.fileManagerService) var fileManagerService: FileManagerServiceProtocol
    @Injected(\.cloudDocumentsService) var cloudDocumentsService: CloudDocumentsServiceProtocol

    public init() {}
}

extension FileManagerSyncService: FileManagerSyncServiceProtocol {
    private func downloadFromCloud(url: URL?) async throws {
        if let url, url.fileExists() == false {
            try FileManager.default.startDownloadingUbiquitousItem(at: url)
        }
    }

    public func isICloudContainerAvailable() -> Result<Bool, Error> {
        if FileManager.default.ubiquityIdentityToken != nil {
            return .success(true)
        }
        return .failure(CloudError.noAccount)
    }

    public func generateUrl(urlString: String?, location: FileLocation, folder: String?, file: String?) async -> Result<URL, Error> {
        if URL(string: urlString.valueOrEmpty)?.fileExists() ?? false {
            guard let url = URL(string: urlString.valueOrEmpty) else {
                return .failure(FileError.fetchFailed)
            }
            return .success(url)
        }
        if location == .iCloud {
            let url = await cloudDocumentsService.giveURL(folder: folder, file: file ?? "file", containerId: nil)
            do {
                try await downloadFromCloud(url: url)
            } catch {
                return .failure(CloudError.fetchFailed)
            }
        } else {
            let url = await fileManagerService.giveURL(folder: folder, file: file ?? "file")
            if url?.fileExists() ?? false {
                guard let url else { return .failure(FileError.fetchFailed) }
                return .success(url)
            }
        }
        switch location {
        case .iCloud:
            return .failure(CloudError.fetchFailed)
        case .local:
            return .failure(FileError.fetchFailed)
        }
    }

    public func deleteDocument(urlString: String?, location: FileLocation, folder: String?, file: String?) async -> Result<Bool, Error> {
        let result = await generateUrl(urlString: urlString, location: location, folder: folder, file: file)
        switch result {
        case let .success(url):
            if location == .local, !url.fileExists() {
                return .failure(FileError.deleteFailed)
            }
            let status = isICloudContainerAvailable()
            switch status {
            case .success:
                return await fileManagerService.removeDocument(localURL: url)
            case .failure:
                return await cloudDocumentsService.removeDocument(icloudUrl: url)
            }
        case let .failure(error):
            return .failure(error)
        }
    }

    public func saveDocument(fileURL: URL, folder: String?, location: FileLocation) async -> Result<URL, Error> {
        switch location {
        case .iCloud:
            let status = isICloudContainerAvailable()
            switch status {
            case .success:
                return await cloudDocumentsService.saveDocument(localDocumentsURL: fileURL, folder: folder, containerId: nil)
            case let .failure(error):
                return .failure(error)
            }
        case .local:
            return await fileManagerService.saveDocument(pickedURL: fileURL, folder: folder)
        }
    }
}
