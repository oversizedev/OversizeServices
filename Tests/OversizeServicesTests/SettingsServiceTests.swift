//
// Copyright © 2026 Alexander Romanov
// SettingsServiceTests.swift
//

import FactoryKit
import FactoryTesting
import Foundation
@testable import OversizeServices
import Testing

@Suite(.serialized)
final class SettingsServiceTests {
    private static let keys: [String] = [
        SettingsService.Keys.notificationsEnabled,
        SettingsService.Keys.soundsEnabled,
        SettingsService.Keys.vibrationEnabled,
        SettingsService.Keys.cloudKitEnabled,
        SettingsService.Keys.cloudKitCVVEnabled,
        SettingsService.Keys.healthKitEnabled,
        SettingsService.Keys.biometricEnabled,
        SettingsService.Keys.pinCodeEnabend,
        SettingsService.Keys.blurMinimizeEnabend,
        SettingsService.Keys.appLockTimeout,
        SettingsService.Keys.fastEnter,
    ]

    init() {
        StandardDefaults.remove(keys: Self.keys)
    }

    deinit {
        StandardDefaults.remove(keys: Self.keys)
    }

    @Test
    func defaultValues() {
        let service = SettingsService()

        #expect(service.notificationEnabled == false)
        #expect(service.soundsEnabled == false)
        #expect(service.vibrationEnabled)
        #expect(service.cloudKitEnabled == false)
        #expect(service.cloudKitCVVEnabled == false)
        #expect(service.healthKitEnabled == false)
        #expect(service.biometricEnabled == false)
        #expect(service.pinCodeEnabled == false)
        #expect(service.blurMinimizeEnabled == false)
        #expect(service.fastEnter == false)
        #expect(service.appLockTimeout == 60)
    }

    @Test
    func settingsPersistAcrossInstances() {
        let service = SettingsService()
        service.notificationEnabled = true
        service.appLockTimeout = 120

        let restored = SettingsService()

        #expect(restored.notificationEnabled)
        #expect(restored.appLockTimeout == 120)
    }

    @Test(.container)
    @MainActor
    func biometricChangeEnablesWhenAuthenticationSucceeds() async {
        let biometricService = MockBiometricService(biometricType: .faceID, authenticationResult: true)
        Container.shared.biometricService.register { biometricService }

        let service = SettingsService()
        await service.biometricChange(true)

        #expect(service.biometricEnabled)
        #expect(biometricService.authenticatingReasons == ["Provide Face ID to enable"])
    }

    @Test(.container)
    @MainActor
    func biometricChangeKeepsStateWhenAuthenticationFails() async {
        let biometricService = MockBiometricService(biometricType: .touchID, authenticationResult: false)
        Container.shared.biometricService.register { biometricService }

        let service = SettingsService()
        await service.biometricChange(true)

        #expect(service.biometricEnabled == false)
        #expect(biometricService.authenticatingReasons == ["Provide Touch ID to enable"])
    }

    @Test(.container)
    @MainActor
    func biometricChangeUsesDisableReasonWhenTurningOff() async {
        let biometricService = MockBiometricService(biometricType: .opticID, authenticationResult: true)
        Container.shared.biometricService.register { biometricService }

        let service = SettingsService()
        service.biometricEnabled = true
        await service.biometricChange(false)

        #expect(service.biometricEnabled == false)
        #expect(biometricService.authenticatingReasons == ["Provide Optic ID to disable"])
    }
}
