//
// Copyright © 2022 Alexander Romanov
// SettingsService.swift
//

#if canImport(LocalAuthentication)
import LocalAuthentication
#endif
import FactoryKit
import OversizeCore
import SwiftUI

// MARK: SettingsServiceProtocol

public protocol SettingsServiceProtocol {
    var notificationEnabled: Bool { get set }
    var soundsEnabled: Bool { get set }
    var vibrationEnabled: Bool { get set }
    var cloudKitEnabled: Bool { get set }
    var cloudKitCVVEnabled: Bool { get set }
    var healthKitEnabled: Bool { get set }
    var biometricEnabled: Bool { get }
    var pinCodeEnabled: Bool { get }
    var blurMinimizeEnabled: Bool { get set }
    var appLockTimeout: TimeInterval { get set }
    func getPINCode() -> String
    func setPINCode(pin: String)
    func updatePINCode(oldPIN: String, newPIN: String) async -> Bool
    func isSetPinCode() -> Bool
    func biometricChange(_ newState: Bool) async
}

public final class SettingsService: ObservableObject, SettingsServiceProtocol, @unchecked Sendable {
    @Injected(\.biometricService) var biometricService

    public init() {}

    public enum Keys {
        // App
        public static let notificationsEnabled = "SettingsStore.notificationsEnabled"
        public static let soundsEnabled = "SettingsStore.soundsEnabled"
        public static let vibrationEnabled = "SettingsStore.vibrationEnabled"
        public static let cloudKitEnabled = "SettingsStore.cloudKitEnabled"
        public static let cloudKitCVVEnabled = "SettingsStore.cloudKitCVVEnabled"
        public static let healthKitEnabled = "SettingsStore.healthKitEnabled"

        // Security
        public static let biometricEnabled = "SettingsStore.biometricEnabled"
        public static let pinCodeEnabend = "SettingsStore.pinCodeEnabend"
        public static let pinCode = "SettingsStore.pinCode"
        public static let blurMinimizeEnabend = "SettingsStore.blurWhenMinimizeEnabend"
        public static let appLockTimeout = "SettingsStore.TimeToLock"
        public static let fastEnter = "SettingsStore.FastEnter"
    }

    // App
    @AppStorage(Keys.notificationsEnabled) public var notificationEnabled: Bool = false
    @AppStorage(Keys.soundsEnabled) public var soundsEnabled: Bool = false
    @AppStorage(Keys.vibrationEnabled) public var vibrationEnabled: Bool = true
    @AppStorage(Keys.cloudKitEnabled) public var cloudKitEnabled: Bool = false
    @AppStorage(Keys.cloudKitCVVEnabled) public var cloudKitCVVEnabled: Bool = false
    @AppStorage(Keys.healthKitEnabled) public var healthKitEnabled: Bool = false

    // Security
    @AppStorage(Keys.biometricEnabled) public var biometricEnabled = false
    @AppStorage(Keys.pinCodeEnabend) public var pinCodeEnabled = false
    @AppStorage(Keys.blurMinimizeEnabend) public var blurMinimizeEnabled = false
    @AppStorage(Keys.appLockTimeout) public var appLockTimeout: TimeInterval = .init(60.0)
    @AppStorage(Keys.fastEnter) public var fastEnter: Bool = false
    @SecureStorage(Keys.pinCode) private var pinCode
}

// PIN Code
public extension SettingsService {
    func getPINCode() -> String {
        logSecurity("Get PIN Code")
        return pinCode ?? ""
    }

    func setPINCode(pin: String) {
        logSecurity("Set PIN Code")
        pinCode = pin
    }

    func updatePINCode(oldPIN: String, newPIN: String) async -> Bool {
        logSecurity("Update PIN Code")
        let currentCode = getPINCode()

        if oldPIN == currentCode {
            pinCode = newPIN
            logSuccess("PIN Code Updated")
            return true
        }
        logError("PIN Code Not updated")
        return false
    }

    func isSetPinCode() -> Bool {
        let pinCode = getPINCode()
        if pinCode == "" {
            return false
        } else {
            return true
        }
    }

    @available(*, deprecated, message: "Use isSetPinCode() instead")
    func isSetedPinCode() -> Bool {
        isSetPinCode()
    }
}

// Biometric

public extension SettingsService {
    @MainActor
    func biometricChange(_ newState: Bool) async {
        logSecurity("Request biometric \(newState ? "enable" : "disable")")
        var reason = ""
        if newState {
            reason = "Provide \(biometricService.biometricType.rawValue) to enable"
        } else {
            reason = "Provide \(biometricService.biometricType.rawValue) to disable"
        }
        let auth = await biometricService.authenticating(reason: reason)
        if auth {
            logSuccess("Enabled biometric authentication")
            biometricEnabled = newState
        }
    }
}
