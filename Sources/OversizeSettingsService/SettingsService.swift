//
// Copyright © 2022 Alexander Romanov
// SettingsService.swift
//

#if os(iOS)
    import LocalAuthentication
#endif
import OversizeCore
import OversizeSecurityService
import OversizeServices
import SwiftUI

// MARK: SettingsServiceProtocol

public protocol SettingsServiceProtocol {
    var notificationEnabled: Bool { get set }
    var soundsEnabled: Bool { get set }
    var vibrationEnabled: Bool { get set }
    var cloudKitEnabled: Bool { get set }
    var cloudKitCVVEnabled: Bool { get set }
    var biometricEnabled: Bool { get set }
    var biometricWhenGetCVVEnabend: Bool { get set }
    var pinCodeEnabend: Bool { get set }
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
    func updatePINCode(oldPIN: String, newPIN: String, completion: @escaping (Bool) -> Void) -> Void
    func isSetedPinCode() -> Bool
    func biometricChange(_ newState: Bool) -> Void
    func biometricWhenGetCVVChange(_ newState: Bool) -> Void
}

public final class SettingsService: ObservableObject, SettingsServiceProtocol {
    @Injected(\.biometricService) var biometricService

    public init() {}

    private enum Keys {
        // App
        static let notificationsEnabled = "SettingsStore.notificationsEnabled"
        static let soundsEnabled = "SettingsStore.soundsEnabled"
        static let vibrationEnabled = "SettingsStore.vibrationEnabled"
        static let cloudKitEnabled = "SettingsStore.cloudKitEnabled"
        static let cloudKitCVVEnabled = "SettingsStore.cloudKitCVVEnabled"

        // Security
        static let biometricEnabled = "SettingsStore.biometricEnabled"
        static let biometricWhenGetCVVEnabend = "SettingsStore.faceIdWhenGetCVVEnabend"
        static let pinCodeEnabend = "SettingsStore.pinCodeEnabend"
        static let pinCode = "SettingsStore.pinCode"
        static let bruteForceSecurityEnabled = "SettingsStore.bruteForceSecurityEnabled"
        static let spotlightEnabled = "SettingsStore.spotlightEnabled"
        static let alertPINCodeEnabled = "SettingsStore.alertPINCodeEnabled"
        static let alertPINCode = "SettingsStore.alertPINCode"
        static let photoBreakerEnabend = "SettingsStore.photoBreakerEnabend"
        static let facedownLockEnabend = "SettingsStore.facedownLockEnabend"
        static let blurMinimizeEnabend = "SettingsStore.blurWhenMinimizeEnabend"
        static let authHistoryEnabend = "SettingsStore.authHistoryEnabend"
        static let askPasswordWhenInactiveEnabend = "SettingsStore.askPasswordWhenInactiveEnabend"
        static let askPasswordAfterMinimizeEnabend = "SettingsStore.askPasswordAfterMinimizeEnabend"
    }

    // App
    @AppStorage(Keys.notificationsEnabled) public var notificationEnabled: Bool = false
    @AppStorage(Keys.soundsEnabled) public var soundsEnabled: Bool = false
    @AppStorage(Keys.vibrationEnabled) public var vibrationEnabled: Bool = true
    @AppStorage(Keys.cloudKitEnabled) public var cloudKitEnabled: Bool = false
    @AppStorage(Keys.cloudKitCVVEnabled) public var cloudKitCVVEnabled: Bool = false

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
        log(pinCode)
        return pinCode ?? ""
    }

    func setPINCode(pin: String) {
        pinCode = pin
    }

    func updatePINCode(oldPIN: String, newPIN: String, completion: @escaping (Bool) -> Void) {
        let currentCode = getPINCode()

        if oldPIN == currentCode {
            pinCode = newPIN

            completion(true)
        }
        completion(false)
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
    func biometricChange(_ newState: Bool) {
        Task {
            var reason = ""
            if newState {
                reason = "Provice \(biometricService.biometricType.rawValue) to enable"
            } else {
                reason = "Provice \(biometricService.biometricType.rawValue) to disable"
            }
            let auth = await biometricService.authenticating(reason: reason)
            if auth {
                biometricEnabled = newState
            }
        }
    }

    func biometricWhenGetCVVChange(_ newState: Bool) {
        Task {
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
}
