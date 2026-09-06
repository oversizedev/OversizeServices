//
// Copyright © 2026 Alexander Romanov
// AppStoreReviewServiceTests.swift
//

import Foundation
@testable import OversizeStoreService
import Testing

@Suite(.serialized)
final class AppStoreReviewServiceTests {
    private static let keys: [String] = [
        "AppState.AppStoreReviewReceivedActionsCount",
        "AppState.isAppReviewBannerClosed",
        "AppState.isAppReviewd",
        "AppState.isAppGoodRating",
        "AppState.appReviewBannerClosedDate",
        "AppState.appReviewEstimateDate",
    ]

    init() {
        StandardDefaults.remove(keys: Self.keys)
    }

    deinit {
        StandardDefaults.remove(keys: Self.keys)
    }

    @Test
    func reviewBannerIsHiddenAfterItWasClosed() async {
        let service = AppStoreReviewService()

        await service.reviewBannerClosed()

        #expect(await service.isShowReviewBanner == false)
    }

    @Test
    func reviewBannerAndSheetAreHiddenAfterEstimate() async {
        let service = AppStoreReviewService()

        await service.estimate(goodRating: true)

        #expect(await service.isShowReviewBanner == false)
        #expect(await service.isShowReviewSheet == false)
    }

    @Test
    func estimateClosesBannerAndStoresDate() async {
        let service = AppStoreReviewService()
        let before = Date()

        await service.estimate(goodRating: false)

        #expect(await service.appReviewEstimateDate >= before)
        #expect(await service.appReviewBannerClosedDate >= before)
    }

    @Test
    func actionEventIncrementsReceivedActionsCount() async {
        let service = AppStoreReviewService()
        let initial = await service.appStoreReviewReceivedActionsCount

        await service.actionEvent()

        #expect(await service.appStoreReviewReceivedActionsCount == initial + 1)
    }

    @Test
    func reviewScheduleContainsExpectedMilestones() async {
        let service = AppStoreReviewService()

        #expect(await service.launchReviewCount.first == 3)
        #expect(await service.rewiewAfterEventCount.first == 0)
        #expect(await service.launchReviewCount == service.launchReviewCount.sorted())
        #expect(await service.rewiewAfterEventCount == service.rewiewAfterEventCount.sorted())
    }
}
