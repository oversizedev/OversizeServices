//
// Copyright © 2022 Alexander Romanov
// AppStateService.swift
//

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
    }

    @AppStorage(Keys.appRunCount) public var appRunCount: Int = 0
    @AppStorage(Keys.isShowOnbarding) public var isShowOnbarding: Bool = false
    @AppStorage(Keys.isCompletedOnbarding) public var isCompletedOnbarding: Bool = false
    @AppStorage(Keys.onbardingPage) public var onbardingPage: Int = 0

    public func appRun() {
        appRunCount += 1
    }

    public func completedOnbarding() {
        isCompletedOnbarding = true
    }

    public func restOnbarding() {
        onbardingPage = 0
        isCompletedOnbarding = false
    }
}
