//
// Copyright © 2022 Alexander Romanov
// ServiceRegistering.swift
//

import Foundation

public extension Container {
    static var appStateService = Factory { AppStateService() }
    static var settingsService = Factory<SettingsServiceProtocol> { SettingsService() }
    static var biometricService = Factory<BiometricServiceProtocol> { BiometricService() }
}
