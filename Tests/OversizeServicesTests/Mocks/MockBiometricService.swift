//
// Copyright © 2026 Alexander Romanov
// MockBiometricService.swift
//

import Foundation
import OversizeServices

final class MockBiometricService: BiometricServiceProtocol, @unchecked Sendable {
    private let isAvailable: Bool
    private let authenticationResult: Bool
    private let reasons: LockedBox<[String]> = .init([])

    let biometricType: BiometricType

    init(
        biometricType: BiometricType = .faceID,
        isAvailable: Bool = true,
        authenticationResult: Bool = true,
    ) {
        self.biometricType = biometricType
        self.isAvailable = isAvailable
        self.authenticationResult = authenticationResult
    }

    var authenticatingReasons: [String] {
        reasons.current
    }

    func checkIfBioMetricAvailable() -> Bool {
        isAvailable
    }

    func authenticating(reason: String) async -> Bool {
        reasons.mutate { $0.append(reason) }
        return authenticationResult
    }
}
