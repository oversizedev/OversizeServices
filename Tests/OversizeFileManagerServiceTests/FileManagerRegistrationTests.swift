//
// Copyright © 2026 Alexander Romanov
// FileManagerRegistrationTests.swift
//

import FactoryKit
import FactoryTesting
@testable import OversizeFileManagerService
import Testing

struct FileManagerRegistrationTests {
    @Test(.container)
    func defaultRegistrationsResolveToProductionTypes() {
        #expect(Container.shared.fileManagerService() is FileManagerService)
        #expect(Container.shared.cloudDocumentsService() is CloudDocumentsService)
        #expect(Container.shared.fileManagerSyncService() is FileManagerSyncService)
    }

    @Test(.container)
    func registeredMocksReplaceProductionTypes() {
        Container.shared.fileManagerService.register { MockFileManagerService() }
        Container.shared.cloudDocumentsService.register { MockCloudDocumentsService() }

        #expect(Container.shared.fileManagerService() is MockFileManagerService)
        #expect(Container.shared.cloudDocumentsService() is MockCloudDocumentsService)
    }
}
