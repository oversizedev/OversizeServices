//
// Copyright © 2026 Alexander Romanov
// AppStateServiceTests.swift
//

import FactoryKit
import Foundation
@testable import OversizeServices
import Testing

@Suite(.serialized)
final class AppStateServiceTests {
    private static let keys: [String] = [
        AppStateService.Keys.appRunCount,
        AppStateService.Keys.appRunDate,
        AppStateService.Keys.isShowOnboarding,
        AppStateService.Keys.isCompletedOnboarding,
        AppStateService.Keys.onboardingPage,
        AppStateService.Keys.lastRunDate,
        AppStateService.Keys.firstRunDate,
        AppStateService.Keys.lastRunVersion,
    ]

    init() {
        StandardDefaults.remove(keys: Self.keys)
    }

    deinit {
        StandardDefaults.remove(keys: Self.keys)
    }

    @Test
    func appRunIncrementsRunCount() {
        let service = AppStateService()

        service.appRun()
        #expect(service.appRunCount == 1)

        service.appRun()
        #expect(service.appRunCount == 2)
    }

    @Test
    func appRunSetsFirstRunDateOnlyOnFirstLaunch() {
        let service = AppStateService()

        service.appRun()
        let firstRunDate = service.firstRunDate

        service.appRun()
        #expect(service.firstRunDate == firstRunDate)
        #expect(service.lastRunDate >= firstRunDate)
    }

    @Test
    func appRunStoresCurrentVersion() {
        let service = AppStateService()

        service.appRun()

        #expect(service.lastRunVersion == Info.App.version?.description ?? "")
    }

    @Test
    func completedOnboardingSetsFlag() {
        let service = AppStateService()
        #expect(service.isCompletedOnboarding == false)

        service.completedOnboarding()

        #expect(service.isCompletedOnboarding)
    }

    @Test
    func resetOnboardingClearsProgress() {
        let service = AppStateService()
        service.completedOnboarding()
        service.onboardingPage = 3

        service.resetOnboarding()

        #expect(service.isCompletedOnboarding == false)
        #expect(service.onboardingPage == 0)
    }

    @Test
    func resetAppRunCountClearsCounterOnly() {
        let service = AppStateService()
        service.appRun()
        let firstRunDate = service.firstRunDate

        service.resetAppRunCount()

        #expect(service.appRunCount == 0)
        #expect(service.firstRunDate == firstRunDate)
    }

    @Test
    func statePersistsAcrossInstances() {
        AppStateService().appRun()

        #expect(AppStateService().appRunCount == 1)
    }
}
