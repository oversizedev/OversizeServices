//
// Copyright © 2022 Alexander Romanov
// ServiceRegistering.swift
//

import Foundation
import OversizeServices

private struct HealthKitServiceKey: InjectionKey {
    static var currentValue: HealthKitServiceProtocol = HealthKitService()
}

public extension InjectedValues {
    var healthKitService: HealthKitServiceProtocol {
        get { Self[HealthKitServiceKey.self] }
        set { Self[HealthKitServiceKey.self] = newValue }
    }
}

// public extension Container {
//    static var healthKitService = Factory<HealthKitServiceProtocol> { HealthKitService() }
// }
