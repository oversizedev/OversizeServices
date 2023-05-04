//
// Copyright © 2022 Alexander Romanov
// ServiceRegistering.swift
//

import Factory
import Foundation
import OversizeServices

public extension Container {
    var healthKitService: Factory<HealthKitServiceProtocol> {
        self { HealthKitService() }
    }
}
