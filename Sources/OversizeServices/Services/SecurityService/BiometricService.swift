//
// Copyright © 2022 Alexander Romanov
// BiometricService.swift
//

import Foundation
import OversizeCore
#if canImport(LocalAuthentication)
    import LocalAuthentication
#endif

public enum BiometricType: String, Sendable {
    case none = ""
    case touchID = "Touch ID"
    case faceID = "Face ID"
    case opticID = "Optic ID"
}

public protocol BiometricServiceProtocol: Sendable {
    var biometricType: BiometricType { get }
    func checkIfBioMetricAvailable() -> Bool
    func authenticating(reason: String) async -> Bool
}

public class BiometricService: @unchecked Sendable {
    public init() {}

    public var biometricType: BiometricType {
        #if canImport(LocalAuthentication)
            let authContext: LAContext = .init()
            _ = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
            switch authContext.biometryType {
            case .none:
                return .none
            case .touchID:
                return .touchID
            case .faceID:
                return .faceID
            case .opticID:
                return .opticID
            @unknown default:
                return .none
            }
        #else
            return .none
        #endif
    }
}

extension BiometricService: BiometricServiceProtocol {
    public func checkIfBioMetricAvailable() -> Bool {
        #if canImport(LocalAuthentication)
            var error: NSError?
            let laContext: LAContext = .init()

            let isBimetricAvailable = laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
            if let error {
                log(error.localizedDescription)
            }

            return isBimetricAvailable
        #else
            return false
        #endif
    }

    public func authenticating(reason: String) async -> Bool {
        #if canImport(LocalAuthentication)
            do {
                let laContext: LAContext = .init()
                if checkIfBioMetricAvailable() {
                    return try await laContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
                } else {
                    return false
                }
            } catch {
                return false
            }
        #else
            return false
        #endif
    }
}
