//
// Copyright © 2022 Alexander Romanov
// ServiceRegistering.swift
//

import Factory
import Foundation
import OversizeServices

public extension Container {
    var fileManagerService: Factory<FileManagerServiceProtocol> {
        self { FileManagerService() }
    }

    var cloudDocumentsService: Factory<CloudDocumentsServiceProtocol> {
        self { CloudDocumentsService() }
    }

    var fileManagerSyncService: Factory<FileManagerSyncServiceProtocol> {
        self { FileManagerSyncService() }
    }
}
