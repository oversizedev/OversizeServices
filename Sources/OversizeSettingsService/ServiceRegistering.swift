//
// Copyright © 2022 Alexander Romanov
// ServiceRegistering.swift
//

import Foundation
import OversizeServices

private struct AppStateServiceKey: InjectionKey {
    static var currentValue: AppStateService = .init()
}

public extension InjectedValues {
    var appStateService: AppStateService {
        get { Self[AppStateServiceKey.self] }
        set { Self[AppStateServiceKey.self] = newValue }
    }
}

private struct SettingsServiceKey: InjectionKey {
    static var currentValue: SettingsServiceProtocol = SettingsService()
}

public extension InjectedValues {
    var settingsService: SettingsServiceProtocol {
        get { Self[SettingsServiceKey.self] }
        set { Self[SettingsServiceKey.self] = newValue }
    }
}
