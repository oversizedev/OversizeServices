//
// Copyright © 2022 Alexander Romanov
// ServiceRegistering.swift
//

import Foundation
import OversizeServices
import Factory

public extension Container {
     var dressWeatherCloudKitService: Factory<DressWeatherCloudKitServiceProtocol> {
         self { DressWeatherCloudKitService() }
     }
}
