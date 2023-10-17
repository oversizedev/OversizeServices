//
// Copyright © 2022 Alexander Romanov
// ServiceRegistering.swift
//

import Factory
import Foundation

public extension Container {
    var dressWeatherCloudKitService: Factory<DressWeatherCloudKitServiceProtocol> {
        self { DressWeatherCloudKitService() }
    }
}
