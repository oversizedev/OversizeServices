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
        public static let isShowOnbarding = "AppState.isShowOnbarding"
        public static let isCompletedOnbarding = "AppState.isCompletedOnbarding"
        public static let onbardingPage = "AppState.onbardingPage"
        public static let lastRunDate = "AppState.lastRunDate"
        public static let firstRunDate = "AppState.firstRunDate"
    }

    @AppStorage(Keys.appRunCount) public var appRunCount: Int = .init(0)
    @AppStorage(Keys.isShowOnbarding) public var isShowOnbarding: Bool = .init(false)
    @AppStorage(Keys.isCompletedOnbarding) public var isCompletedOnbarding: Bool = .init(false)
    @AppStorage(Keys.onbardingPage) public var onbardingPage: Int = .init(0)
    @AppStorage(Keys.lastRunDate) public var lastRunDate: Date = .init()
    @AppStorage(Keys.firstRunDate) private var firstRunDate: Date = .init()

    public func appRun() {
        if appRunCount == 0 {
            firstRunDate = Date()
        }
        appRunCount += 1
        lastRunDate = Date()
    }

    public func completedOnbarding() {
        isCompletedOnbarding = true
        logSuccess("Onbarding completed")
    }

    public func restOnbarding() {
        onbardingPage = 0
        isCompletedOnbarding = false
        logSuccess("Onbarding rested")
    }

    public func restAppRunCount() {
        appRunCount = 0
    }
}
