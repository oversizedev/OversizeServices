//
// Copyright © 2022 Alexander Romanov
// ServiceRegistering.swift
//

import Foundation
import OversizeServices

private struct BiometricServiceKey: InjectionKey {
    static var currentValue: BiometricServiceProtocol = BiometricService()
}

public extension InjectedValues {
    var biometricService: BiometricServiceProtocol {
        get { Self[BiometricServiceKey.self] }
        set { Self[BiometricServiceKey.self] = newValue }
    }
}
