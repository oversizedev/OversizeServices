//
// Copyright © 2022 Alexander Romanov
// ServiceRegistering.swift
//

import FactoryKit
import Foundation

public extension Container {
    var locationService: Factory<LocationServiceProtocol> {
        self { LocationService() }
    }
}
