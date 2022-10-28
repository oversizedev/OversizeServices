//
//  File.swift
//  
//
//  Created by aromanov on 29.10.2022.
//

import Foundation
import OversizeServices

public extension Container {
    static var locationService = Factory<LocationServiceProtocol> { LocationService() }
}
