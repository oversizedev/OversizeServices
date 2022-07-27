//
// Copyright © 2022 Alexander Romanov
// ResolverRegistering.swift
//

import Foundation
import OversizeServices

private struct HealthKitServiceKey: InjectionKey {
    static var currentValue: HealthKitServiceProtocol = HealthKitService()
}

extension InjectedValues {
    public var healthKitService: HealthKitServiceProtocol {
        get { Self[HealthKitServiceKey.self] }
        set { Self[HealthKitServiceKey.self] = newValue }
    }
}
