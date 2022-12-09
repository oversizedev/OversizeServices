//
// Copyright © 2022 Alexander Romanov
// BiometricService.swift
//

import Foundation
import OversizeCore
#if canImport(LocalAuthentication)
    import LocalAuthentication
#endif

public enum BiometricType: String {
    case none = ""
    case touchID = "Touch ID"
    case faceID = "Face ID"
}

public protocol BiometricServiceProtocol {
    var biometricType: BiometricType { get }
    func checkIfBioMetricAvailable() -> Bool
    func authenticating(reason: String) async -> Bool
}

public class BiometricService {
    public init() {}

    public var biometricType: BiometricType {
        #if os(iOS)
            let authContext: LAContext = .init()
            _ = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
            switch authContext.biometryType {
            case .none:
                return .none
            case .touchID:
                return .touchID
            case .faceID:
                return .faceID
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
        #if os(iOS)
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
        #if os(iOS)
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
