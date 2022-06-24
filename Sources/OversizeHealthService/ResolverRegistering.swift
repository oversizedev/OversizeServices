//
// Copyright © 2022 Alexander Romanov
// ResolverRegistering.swift
//

import Foundation

extension Resolver: ResolverRegistering {
    
    public static func registerAllServices() {
    
        // MARK: - HealthKit
        register { HealthKitService() }.implements(HealthKitServiceProtocol.self)
    }
}
