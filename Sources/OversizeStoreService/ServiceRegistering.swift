//
// Copyright © 2022 Alexander Romanov
// ServiceRegistering.swift
//

import Foundation
import OversizeServices

private struct AppStoreReviewServiceKey: InjectionKey {
    static var currentValue: AppStoreReviewServiceProtocol = AppStoreReviewService()
}

public extension InjectedValues {
    var appStoreReviewService: AppStoreReviewServiceProtocol {
        get { Self[AppStoreReviewServiceKey.self] }
        set { Self[AppStoreReviewServiceKey.self] = newValue }
    }
}

private struct StoreKitServiceKey: InjectionKey {
    static var currentValue: StoreKitService = .init()
}

public extension InjectedValues {
    var storeKitService: StoreKitService {
        get { Self[StoreKitServiceKey.self] }
        set { Self[StoreKitServiceKey.self] = newValue }
    }
}
