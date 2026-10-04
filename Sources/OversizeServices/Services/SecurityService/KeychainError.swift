//
// Copyright © 2026 Alexander Romanov
// KeychainError.swift, created on 03.10.2026
//

import Foundation
import Security

public enum KeychainError: Error, Equatable, Sendable {
    case unavailable(OSStatus)
    case encodingFailed
    case decodingFailed
    case serviceRequired
}

extension KeychainError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .unavailable(status):
            SecCopyErrorMessageString(status, nil) as String? ?? "Keychain error \(status)"
        case .encodingFailed:
            "The value could not be encoded for the Keychain"
        case .decodingFailed:
            "The Keychain item could not be decoded"
        case .serviceRequired:
            "The operation needs a Keychain service"
        }
    }
}
