//
// Copyright © 2022 Alexander Romanov
// ServiceRegistering.swift
//

import Factory
import Foundation
import OversizeServices

public extension Container {
    var locationService: Factory<LocationServiceProtocol> {
        self { LocationService() }
    }
}
