//
// Copyright © 2022 Alexander Romanov
// ServiceRegistering.swift
//

import Foundation
import OversizeServices

public extension Container {
    static var dressWeatherCloudKitService = Factory<DressWeatherCloudKitServiceProtocol> { DressWeatherCloudKitService() }
}
