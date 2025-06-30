//
// Copyright © 2022 Alexander Romanov
// AppStoreReviewService.swift
//

import OversizeCore
import StoreKit
import SwiftUI

// MARK: AppStoreReviewService

public actor AppStoreReviewService {
    private enum Keys {
        static let appRunCount = "AppState.appRunCount"
        static let appStoreReviewReceivedActionsCount = "AppState.AppStoreReviewReceivedActionsCount"
        static let isAppReviewBannerClosed = "AppState.isAppReviewBannerClosed"
        static let isAppReviewed = "AppState.isAppReviewd"
        static let isAppGoodRating = "AppState.isAppGoodRating"
        static let appReviewBannerClosedDate = "AppState.appReviewBannerClosedDate"
        static let appReviewEstimateDate = "AppState.appReviewEstimateDate"
    }

    @AppStorage(Keys.appRunCount) private var appRunCount: Int = 0
    @AppStorage(Keys.appStoreReviewReceivedActionsCount) public var appStoreReviewReceivedActionsCount: Int = 0
    @AppStorage(Keys.isAppReviewBannerClosed) private var isAppReviewBannerClosed = false
    @AppStorage(Keys.isAppReviewed) private var isAppReviewed = false
    @AppStorage(Keys.isAppGoodRating) private var isAppGoodRating = false
    @AppStorage(Keys.appReviewBannerClosedDate) public var appReviewBannerClosedDate: Date = .init()
    @AppStorage(Keys.appReviewEstimateDate) public var appReviewEstimateDate: Date = .init()

    public let launchReviewCount: [Int] = .init([3, 5, 8, 10, 20, 30, 50, 80, 100, 150, 200, 300, 400, 500])
    public let rewiewAfterEventCount: [Int] = .init([0, 2, 5, 10, 20, 30, 50, 80, 100, 150, 200, 300, 400, 500])
    private let rewiewBannerShowingCount: [Int] = .init([2, 4, 5, 20, 45, 70, 90, 140, 180, 234, 245, 454, 699])
    private let rewiewSheetShowingCount: [Int] = .init([3, 25, 50, 80, 100, 150, 200, 300, 400, 500])

    public init() {}
}

public extension AppStoreReviewService {
    var isShowReviewBanner: Bool {
        if !isAppReviewBannerClosed, appRunCount > 1 /*  appReviewBannerClosedDate.dayAfter < Date()*/, !isAppReviewed {
            rewiewBannerShowingCount.contains(appRunCount)
        } else {
            false
        }
    }

    var isShowReviewSheet: Bool {
        if !isAppReviewed {
            rewiewSheetShowingCount.contains(appRunCount)
        } else {
            false
        }
    }

    func launchEvent() async {
        if launchReviewCount.contains(appRunCount) {
            await showSystemRewiewAlert()
            if appReviewBannerClosedDate.weekAfter < Date() {
                isAppReviewBannerClosed = false
            }
        }
    }

    func actionEvent() async {
        appStoreReviewReceivedActionsCount += 1
        if rewiewAfterEventCount.contains(appStoreReviewReceivedActionsCount) {
            await showSystemRewiewAlert()
        }
    }

    func reviewBannerClosed() {
        appReviewBannerClosedDate = Date()
        isAppReviewBannerClosed = true
    }

    func estimate(goodRating: Bool) {
        isAppReviewed = true
        isAppGoodRating = goodRating
        appReviewEstimateDate = Date()
        reviewBannerClosed()
    }
}

private extension AppStoreReviewService {
    func showSystemRewiewAlert() async {
        #if os(iOS)
        await MainActor.run {
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
        #endif
    }
}
