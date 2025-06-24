//
// Copyright © 2022 Alexander Romanov
// ServiceRegistering.swift
//

import FactoryKit
import Foundation

public extension Container {
    var appStoreReviewService: Factory<AppStoreReviewService> {
        self { AppStoreReviewService() }
    }

    var storeKitService: Factory<StoreKitService> {
        self { StoreKitService() }
    }
}
