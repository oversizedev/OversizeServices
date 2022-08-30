//
// Copyright © 2022 Alexander Romanov
// AppStoreReviewService.swift
//

import StoreKit
import SwiftUI

// MARK: AppStoreReviewServiceProtocol

public protocol AppStoreReviewServiceProtocol {
    func appRunRequest() -> Void
    func actionRequest() -> Void
}

// MARK: AppStoreReviewService

public class AppStoreReviewService {
    public init() {}

    private enum Keys {
        static let appRunCount = "AppState.appRunCount"
        static let appStoreReviewRequestCount = "AppState.appStoreReviewRequestCount"
    }

    @AppStorage(Keys.appRunCount) private var appRunCount: Int = 0
    @AppStorage(Keys.appRunCount) private var appStoreReviewRequestCount: Int = 0
    private let runReviewCount = [1, 3, 5, 8, 10, 20, 30, 50, 80, 100, 150, 200, 300, 400, 500]

    private let actionEventCount = [0, 2, 3, 5, 8, 10, 20, 30, 50, 80, 100, 150, 200, 300, 400, 500]
}

extension AppStoreReviewService: AppStoreReviewServiceProtocol {
    public func appRunRequest() {
        #if os(iOS)
            for runReviewActionEvent in runReviewCount where appRunCount == runReviewActionEvent {
                if let scene = UIApplication.shared.connectedScenes
                    .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
                {
                    SKStoreReviewController.requestReview(in: scene)
                }
            }
        #endif
    }

    public func actionRequest() {
        #if os(iOS)
            for actionEvent in actionEventCount where appStoreReviewRequestCount == actionEvent {
                if let scene = UIApplication.shared.connectedScenes
                    .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
                {
                    SKStoreReviewController.requestReview(in: scene)
                    appStoreReviewRequestCount += 1
                }
            }
        #endif
    }
}
