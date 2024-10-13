//
// Copyright © 2022 Alexander Romanov
// AppStateService.swift
//

import OversizeCore
import SwiftUI

// public protocol AppStateServiceProtocol: ObservableObject {
//    var appRunCount: Int { get }
//    var isShowOnbarding: Bool { get set }
//    var isCompletedOnbarding: Bool { get set }
//    var onbardingPage: Int { get set }
//    func appRun()
//    func completedOnbarding()
//    func restOnbarding()
// }

public final class AppStateService: ObservableObject { //: AppStateServiceProtocol {
    public init() {}

    private enum Keys {
        static let appRunCount = "AppState.appRunCount"
        static let appRunDate = "AppState.appRunDate"
        static let isShowOnbarding = "AppState.isShowOnbarding"
        static let isCompletedOnbarding = "AppState.isCompletedOnbarding"
        static let onbardingPage = "AppState.onbardingPage"
        static let lastRunDate = "AppState.lastRunDate"
        static let firstRunDate = "AppState.firstRunDate"
        // static let lastClosedSpecialOffer = "AppState.lastClosedSpecialOffer"
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
