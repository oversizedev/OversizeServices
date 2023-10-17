//
// Copyright © 2022 Alexander Romanov
// ServiceRegistering.swift
//

import Factory
import Foundation

public extension Container {
    @available(iOS 15, macOS 13.0, *)
    var healthKitService: Factory<HealthKitServiceProtocol> {
        self { HealthKitService() }
    }
}
