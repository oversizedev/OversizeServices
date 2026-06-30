// Copyright © 2026 Alexander Romanov
// ServiceRegistering.swift

#if canImport(WeatherKit)
import FactoryKit
import Foundation

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
public extension Container {
    var weatherService: Factory<OversizeWeatherService> {
        self { OversizeWeatherService() }
    }
}
#endif
