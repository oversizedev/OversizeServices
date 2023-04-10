//
// Copyright © 2022 Alexander Romanov
// ServiceRegistering.swift
//

import Foundation
import Factory

public extension Container {
    var appStateService: Factory<AppStateService> {
        Factory(self) { AppStateService() }
    }
    var settingsService: Factory<SettingsServiceProtocol> {
        self { SettingsService() }
    }
    var biometricService: Factory<BiometricServiceProtocol> {
        self { BiometricService() }
    }
}
