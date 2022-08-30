//
// Copyright © 2022 Alexander Romanov
// BiometricService.swift
//

import Foundation
#if os(iOS)
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
    func authenticating(reason: String, completion: @escaping (Bool) -> Void)
}

public class BiometricService {
    public init() {}

    public var biometricType: BiometricType {
        #if os(iOS)
            let authContext = LAContext()
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
            let laContext = LAContext()

            let isBimetricAvailable = laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
            if let error = error {
                print(error.localizedDescription)
            }

            return isBimetricAvailable
        #else
            return false
        #endif
    }

    public func authenticating(reason: String, completion: @escaping (Bool) -> Void) {
        #if os(iOS)
            let laContext = LAContext()
            if checkIfBioMetricAvailable() {
                laContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, _ in
                    if success {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            }
        #else
            completion(false)
        #endif
    }
}
