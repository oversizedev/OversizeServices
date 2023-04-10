//
// Copyright © 2022 Alexander Romanov
// SettingsService.swift
//

#if os(iOS)
    import LocalAuthentication
#endif
import OversizeCore
import SwiftUI
import Factory

// MARK: SettingsServiceProtocol

public protocol SettingsServiceProtocol {
    var notificationEnabled: Bool { get set }
    var soundsEnabled: Bool { get set }
    var vibrationEnabled: Bool { get set }
    var cloudKitEnabled: Bool { get set }
    var cloudKitCVVEnabled: Bool { get set }
    var healthKitEnabled: Bool { get set }
    var biometricEnabled: Bool { get }
    var biometricWhenGetCVVEnabend: Bool { get }
    var pinCodeEnabend: Bool { get }
    var deleteDataIfBruteForceEnabled: Bool { get set }
    var spotlightEnabled: Bool { get set }
    var alertPINCodeEnabled: Bool { get set }
    var alertPINCode: String { get set }
    var photoBreakerEnabend: Bool { get set }
    var lookScreenDownEnabend: Bool { get set }
    var blurMinimizeEnabend: Bool { get set }
    var authHistoryEnabend: Bool { get set }
    var askPasswordWhenInactiveEnabend: Bool { get set }
    var askPasswordAfterMinimizeEnabend: Bool { get set }
    func getPINCode() -> String
    func setPINCode(pin: String) -> Void
    func updatePINCode(oldPIN: String, newPIN: String) async -> Bool
    func isSetedPinCode() -> Bool
    func biometricChange(_ newState: Bool) async
    func biometricWhenGetCVVChange(_ newState: Bool) async
}

public final class SettingsService: ObservableObject, SettingsServiceProtocol {
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
        public static let biometricWhenGetCVVEnabend = "SettingsStore.faceIdWhenGetCVVEnabend"
        public static let pinCodeEnabend = "SettingsStore.pinCodeEnabend"
        public static let pinCode = "SettingsStore.pinCode"
        public static let bruteForceSecurityEnabled = "SettingsStore.bruteForceSecurityEnabled"
        public static let spotlightEnabled = "SettingsStore.spotlightEnabled"
        public static let alertPINCodeEnabled = "SettingsStore.alertPINCodeEnabled"
        public static let alertPINCode = "SettingsStore.alertPINCode"
        public static let photoBreakerEnabend = "SettingsStore.photoBreakerEnabend"
        public static let facedownLockEnabend = "SettingsStore.facedownLockEnabend"
        public static let blurMinimizeEnabend = "SettingsStore.blurWhenMinimizeEnabend"
        public static let authHistoryEnabend = "SettingsStore.authHistoryEnabend"
        public static let askPasswordWhenInactiveEnabend = "SettingsStore.askPasswordWhenInactiveEnabend"
        public static let askPasswordAfterMinimizeEnabend = "SettingsStore.askPasswordAfterMinimizeEnabend"
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
    @AppStorage(Keys.biometricWhenGetCVVEnabend) public var biometricWhenGetCVVEnabend = false
    @AppStorage(Keys.pinCodeEnabend) public var pinCodeEnabend = false
    @AppStorage(Keys.bruteForceSecurityEnabled) public var deleteDataIfBruteForceEnabled = false
    @AppStorage(Keys.spotlightEnabled) public var spotlightEnabled = false
    @AppStorage(Keys.alertPINCodeEnabled) public var alertPINCodeEnabled = false
    @AppStorage(Keys.alertPINCode) public var alertPINCode = ""
    @AppStorage(Keys.photoBreakerEnabend) public var photoBreakerEnabend = false
    @AppStorage(Keys.facedownLockEnabend) public var lookScreenDownEnabend = false
    @AppStorage(Keys.blurMinimizeEnabend) public var blurMinimizeEnabend = false
    @AppStorage(Keys.authHistoryEnabend) public var authHistoryEnabend = false
    @AppStorage(Keys.askPasswordWhenInactiveEnabend) public var askPasswordWhenInactiveEnabend = false
    @AppStorage(Keys.askPasswordAfterMinimizeEnabend) public var askPasswordAfterMinimizeEnabend = false
    @SecureStorage(Keys.pinCode) private var pinCode
}

// PIN Code
public extension SettingsService {
    func getPINCode() -> String {
        log("🔐 Get PIN Code")
        return pinCode ?? ""
    }

    func setPINCode(pin: String) {
        log("🔐 Set PIN Code")
        pinCode = pin
    }

    func updatePINCode(oldPIN: String, newPIN: String) async -> Bool {
        log("🔐 Update PIN Code")
        let currentCode = getPINCode()

        if oldPIN == currentCode {
            pinCode = newPIN
            log("✅ PIN Code Updated")
            return true
        }
        log("🛑 PIN Code Not updated")
        return false
    }

    func isSetedPinCode() -> Bool {
        let pinCode = getPINCode()
        if pinCode == "" {
            return false
        } else {
            return true
        }
    }
}

// Biometric

public extension SettingsService {
    @MainActor
    func biometricChange(_ newState: Bool) async {
        log("🪬 Updated biometric state")
        var reason = ""
        if newState {
            reason = "Provice \(biometricService.biometricType.rawValue) to enable"
        } else {
            reason = "Provice \(biometricService.biometricType.rawValue) to disable"
        }
        let auth = await biometricService.authenticating(reason: reason)
        if auth {
            log("✅ Updated biometric state")
            biometricEnabled = newState
        }
    }

    func biometricWhenGetCVVChange(_ newState: Bool) async {
        var reason = ""
        let biometricType = biometricService.biometricType
        if newState {
            reason = "Provice \(biometricType.rawValue) to enable"
        } else {
            reason = "Provice\(biometricType.rawValue) to disable"
        }
        let auth = await biometricService.authenticating(reason: reason)
        if auth {
            biometricWhenGetCVVEnabend = newState
        }
    }
}
