//
// Copyright © 2022 Alexander Romanov
// ServiceRegistering.swift
//

import Factory
import Foundation

public extension Container {
    var appStoreReviewService: Factory<AppStoreReviewServiceProtocol> {
        self { AppStoreReviewService() }
    }

    var storeKitService: Factory<StoreKitService> {
        self { StoreKitService() }
    }
}
