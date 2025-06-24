//
// Copyright © 2022 Alexander Romanov
// AppStateService.swift
//

import OversizeCore
import SwiftUI

public final class AppStateService: ObservableObject {
    public init() {}

    public enum Keys {
        public static let appRunCount = "AppState.appRunCount"
        public static let appRunDate = "AppState.appRunDate"
        public static let isShowOnboarding = "AppState.isShowOnbarding"
        public static let isCompletedOnboarding = "AppState.isCompletedOnbarding"
        public static let onbardingPage = "AppState.onbardingPage"
        public static let lastRunDate = "AppState.lastRunDate"
        public static let firstRunDate = "AppState.firstRunDate"
        public static let lastRunVersion = "AppState.LastRunVersion"
    }

    @AppStorage(Keys.appRunCount) public var appRunCount: Int = .init()
    @AppStorage(Keys.isShowOnboarding) public var isShowOnboarding: Bool = .init()
    @AppStorage(Keys.isCompletedOnboarding) public var isCompletedOnboarding: Bool = .init()
    @AppStorage(Keys.onbardingPage) public var onboardingPage: Int = .init()
    @AppStorage(Keys.lastRunDate) public var lastRunDate: Date = .init()
    @AppStorage(Keys.firstRunDate) public var firstRunDate: Date = .init()
    @AppStorage(Keys.lastRunVersion) public var lastRunVersion: String = .init()

    public func appRun() {
        if appRunCount == 0 {
            firstRunDate = Date()
        }
        appRunCount += 1
        lastRunDate = Date()
        lastRunVersion = Info.app.version.valueOrEmpty
        logDebugInfo()
    }

    public func completedOnbarding() {
        isCompletedOnboarding = true
        logInfo("Onboarding completed")
    }

    public func restOnbarding() {
        onboardingPage = 0
        isCompletedOnboarding = false
        logInfo("Onboarding rested")
    }

    public func restAppRunCount() {
        appRunCount = 0
        logInfo("App run count rested")
    }

    func logDebugInfo() {
        let debugInfo = """
        Debug Info:
        First Run Date: \(firstRunDate.formatted(date: .abbreviated, time: .standard))
        Last Run Date: \(lastRunDate.formatted(date: .abbreviated, time: .standard))
        App Run Count: \(appRunCount)
        App version: \(lastRunVersion)
        """
        logInfo(debugInfo)
    }
}
