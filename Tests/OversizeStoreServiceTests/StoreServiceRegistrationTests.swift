//
// Copyright © 2026 Alexander Romanov
// StoreServiceRegistrationTests.swift
//

import FactoryKit
import FactoryTesting
@testable import OversizeStoreService
import Testing

struct StoreServiceRegistrationTests {
    @Test(.container)
    func storeServicesAreRegistered() {
        _ = Container.shared.appStoreReviewService()
        _ = Container.shared.storeKitService()
    }

    @Test(.container)
    func storeServicesUseUniqueScope() {
        #expect(Container.shared.appStoreReviewService() !== Container.shared.appStoreReviewService())
        #expect(Container.shared.storeKitService() !== Container.shared.storeKitService())
    }
}
