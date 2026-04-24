// Copyright © 2026 Alexander Romanov
// ServiceRegistering.swift

#if canImport(WeatherKit)
import FactoryKit
import Foundation

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
public extension Container {
    var weatherService: Factory<any WeatherServiceProtocol> {
        self { OversizeWeatherService() }
    }
}
#endif
