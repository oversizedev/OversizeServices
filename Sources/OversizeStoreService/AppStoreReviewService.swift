//
// Copyright © 2022 Alexander Romanov
// AppStoreReviewService.swift
//

import OversizeCore
import StoreKit
import SwiftUI

// MARK: AppStoreReviewServiceProtocol

public protocol AppStoreReviewServiceProtocol {
    func launchEvent()
    func actionEvent()
    func rewiewBunnerClosed()
    func estimate(goodRating: Bool)
    var isShowReviewBanner: Bool { get }
    var isShowReviewSheet: Bool { get }
}

// MARK: AppStoreReviewService

public class AppStoreReviewService {
    private enum Keys {
        static let appRunCount = "AppState.appRunCount"
        static let appStoreReviewRequestCount = "AppState.appStoreReviewRequestCount"
        static let isAppReviewBannerClosed = "AppState.isAppReviewBannerClosed"
        static let isAppReviewd = "AppState.isAppReviewd"
        static let isAppGoodRating = "AppState.isAppGoodRating"
        static let appReviewBannerClosedDate = "AppState.appReviewBannerClosedDate"
        static let appReviewEstimateDate = "AppState.appReviewEstimateDate"
    }

    // @Environment(\.requestReview) var requestReview
    @AppStorage(Keys.appRunCount) private var appRunCount: Int = 0
    @AppStorage(Keys.appStoreReviewRequestCount) private var appStoreReviewRequestCount: Int = 0
    @AppStorage(Keys.isAppReviewBannerClosed) private var isAppReviewBannerClosed = false
    @AppStorage(Keys.isAppReviewd) private var isAppReviewd = false
    @AppStorage(Keys.isAppGoodRating) private var isAppGoodRating = false
    @AppStorage(Keys.appReviewBannerClosedDate) private var appReviewBannerClosedDate: Date = .init()
    @AppStorage(Keys.appReviewEstimateDate) private var appReviewEstimateDate: Date = .init()

    private let launchReviewCount: [Int] = [3, 5, 8, 10, 20, 30, 50, 80, 100, 150, 200, 300, 400, 500]
    private let rewiewAfterEventCount: [Int] = [0, 2, 5, 10, 20, 30, 50, 80, 100, 150, 200, 300, 400, 500]
    private let rewiewBannerShowingCount: [Int] = .init(0 ... 100) // [4, 5, 6, 9, 12, 32, 50, 80, 100, 150, 200, 300, 400, 500]
    private let rewiewSheetShowingCount: [Int] = [8, 25, 30, 50, 80, 100, 150, 200, 300, 400, 500]

    public init() {}
}

extension AppStoreReviewService: AppStoreReviewServiceProtocol {
    public var isShowReviewBanner: Bool {
        if !isAppReviewBannerClosed, appRunCount > 1 /*  appReviewBannerClosedDate.dayAfter < Date()*/, !isAppReviewd {
            return rewiewBannerShowingCount.contains(appRunCount)
        } else {
            return false
        }
    }

    public var isShowReviewSheet: Bool {
        if !isAppReviewd, appRunCount > 1 {
            return rewiewSheetShowingCount.contains(appRunCount)
        } else {
            return false
        }
    }

    public func launchEvent() {
        if launchReviewCount.contains(appRunCount) {
            showSystemRewiewAlert()
            if appReviewBannerClosedDate.weekAfter < Date() {
                isAppReviewBannerClosed = false
            }
        }
    }

    public func actionEvent() {
        if rewiewAfterEventCount.contains(appStoreReviewRequestCount) {
            showSystemRewiewAlert()
            appStoreReviewRequestCount += 1
        }
    }

    public func rewiewBunnerClosed() {
        appReviewBannerClosedDate = Date()
        isAppReviewBannerClosed = true
    }

    public func estimate(goodRating: Bool) {
        isAppReviewd = true
        isAppGoodRating = goodRating
        appReviewEstimateDate = Date()
        rewiewBunnerClosed()
    }
}

private extension AppStoreReviewService {
    func showSystemRewiewAlert() {
        #if os(iOS)
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        #endif
    }
}
