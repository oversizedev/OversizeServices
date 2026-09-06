//
// Copyright © 2026 Alexander Romanov
// MockSettingsService.swift
//

import Foundation
import OversizeServices

final class MockSettingsService: SettingsServiceProtocol {
    var notificationEnabled: Bool = true
    var soundsEnabled: Bool = true
    var vibrationEnabled: Bool = true
    var cloudKitEnabled: Bool = true
    var cloudKitCVVEnabled: Bool = true
    var healthKitEnabled: Bool = true
    var biometricEnabled: Bool = true
    var pinCodeEnabled: Bool = true
    var blurMinimizeEnabled: Bool = true
    var appLockTimeout: TimeInterval = 30

    private(set) var storedPINCode: String = "0000"
    private(set) var biometricChangeStates: [Bool] = []

    func getPINCode() -> String {
        storedPINCode
    }

    func setPINCode(pin: String) {
        storedPINCode = pin
    }

    func updatePINCode(oldPIN: String, newPIN: String) async -> Bool {
        guard oldPIN == storedPINCode else { return false }
        storedPINCode = newPIN
        return true
    }

    func isSetPinCode() -> Bool {
        !storedPINCode.isEmpty
    }

    func biometricChange(_ newState: Bool) async {
        biometricChangeStates.append(newState)
        biometricEnabled = newState
    }
}
