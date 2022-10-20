//
// Copyright © 2022 Alexander Romanov
// ServiceRegistering.swift
//

import Foundation
import OversizeServices

public extension Container {
    static var appStateService = Factory { AppStateService() }
    static var settingsService = Factory<SettingsServiceProtocol> { SettingsService() }
}
