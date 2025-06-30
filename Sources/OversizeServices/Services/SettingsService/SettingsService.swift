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
    var biometricWhenGetCVVEnabled: Bool { get }
    var pinCodeEnabled: Bool { get }
    var deleteDataIfBruteForceEnabled: Bool { get set }
    var spotlightEnabled: Bool { get set }
    var alertPINCodeEnabled: Bool { get set }
    var alertPINCode: String { get set }
    var photoBreakerEnabled: Bool { get set }
    var lockScreenDownEnabled: Bool { get set }
    var blurMinimizeEnabled: Bool { get set }
    var authHistoryEnabled: Bool { get set }
    var askPasswordWhenInactiveEnabled: Bool { get set }
    var askPasswordAfterMinimizeEnabled: Bool { get set }
    var appLockTimeout: TimeInterval { get set }
    func getPINCode() -> String
    func setPINCode(pin: String)
    func updatePINCode(oldPIN: String, newPIN: String) async -> Bool
    func isSetPinCode() -> Bool
    func biometricChange(_ newState: Bool) async
    func biometricWhenGetCVVChange(_ newState: Bool) async
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
    @AppStorage(Keys.biometricWhenGetCVVEnabend) public var biometricWhenGetCVVEnabled = false
    @AppStorage(Keys.pinCodeEnabend) public var pinCodeEnabled = false
    @AppStorage(Keys.bruteForceSecurityEnabled) public var deleteDataIfBruteForceEnabled = false
    @AppStorage(Keys.spotlightEnabled) public var spotlightEnabled = false
    @AppStorage(Keys.alertPINCodeEnabled) public var alertPINCodeEnabled = false
    @AppStorage(Keys.alertPINCode) public var alertPINCode = ""
    @AppStorage(Keys.photoBreakerEnabend) public var photoBreakerEnabled = false
    @AppStorage(Keys.facedownLockEnabend) public var lockScreenDownEnabled = false
    @AppStorage(Keys.blurMinimizeEnabend) public var blurMinimizeEnabled = false
    @AppStorage(Keys.authHistoryEnabend) public var authHistoryEnabled = false
    @AppStorage(Keys.askPasswordWhenInactiveEnabend) public var askPasswordWhenInactiveEnabled = false
    @AppStorage(Keys.askPasswordAfterMinimizeEnabend) public var askPasswordAfterMinimizeEnabled = false
    @AppStorage(Keys.appLockTimeout) public var appLockTimeout: TimeInterval = .init(60.0)
    @AppStorage(Keys.fastEnter) public var fastEnter: Bool = false
    @SecureStorage(Keys.pinCode) private var pinCode

    // Deprecated property aliases for backward compatibility
    @available(*, deprecated, message: "Use biometricWhenGetCVVEnabled instead")
    public var biometricWhenGetCVVEnabend: Bool {
        get { biometricWhenGetCVVEnabled }
        set { biometricWhenGetCVVEnabled = newValue }
    }

    @available(*, deprecated, message: "Use pinCodeEnabled instead")
    public var pinCodeEnabend: Bool {
        get { pinCodeEnabled }
        set { pinCodeEnabled = newValue }
    }

    @available(*, deprecated, message: "Use photoBreakerEnabled instead")
    public var photoBreakerEnabend: Bool {
        get { photoBreakerEnabled }
        set { photoBreakerEnabled = newValue }
    }

    @available(*, deprecated, message: "Use lockScreenDownEnabled instead")
    public var lookScreenDownEnabend: Bool {
        get { lockScreenDownEnabled }
        set { lockScreenDownEnabled = newValue }
    }

    @available(*, deprecated, message: "Use blurMinimizeEnabled instead")
    public var blurMinimizeEnabend: Bool {
        get { blurMinimizeEnabled }
        set { blurMinimizeEnabled = newValue }
    }

    @available(*, deprecated, message: "Use authHistoryEnabled instead")
    public var authHistoryEnabend: Bool {
        get { authHistoryEnabled }
        set { authHistoryEnabled = newValue }
    }

    @available(*, deprecated, message: "Use askPasswordWhenInactiveEnabled instead")
    public var askPasswordWhenInactiveEnabend: Bool {
        get { askPasswordWhenInactiveEnabled }
        set { askPasswordWhenInactiveEnabled = newValue }
    }

    @available(*, deprecated, message: "Use askPasswordAfterMinimizeEnabled instead")
    public var askPasswordAfterMinimizeEnabend: Bool {
        get { askPasswordAfterMinimizeEnabled }
        set { askPasswordAfterMinimizeEnabled = newValue }
    }
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

    func biometricWhenGetCVVChange(_ newState: Bool) async {
        var reason = ""
        let biometricType = biometricService.biometricType
        if newState {
            reason = "Provide \(biometricType.rawValue) to enable"
        } else {
            reason = "Provide \(biometricType.rawValue) to disable"
        }
        let auth = await biometricService.authenticating(reason: reason)
        if auth {
            biometricWhenGetCVVEnabled = newState
        }
    }
}
