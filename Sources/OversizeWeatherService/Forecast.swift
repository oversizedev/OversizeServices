// Copyright © 2026 Alexander Romanov
// Forecast.swift

#if canImport(WeatherKit)
import Foundation
import WeatherKit

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
public struct AppForecast: Sendable {
    public let current: CurrentWeather
    public let hourly: [HourWeather]
    public let daily: [DayWeather]

    public init(current: CurrentWeather, hourly: [HourWeather], daily: [DayWeather]) {
        self.current = current
        self.hourly = hourly
        self.daily = daily
    }
}

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
public extension AppForecast {
    var sunPositionPercent: Double {
        guard let sunrise = daily.first?.sunrise,
              let sunset = daily.first?.sunset else { return 0 }
        let total = sunset.timeIntervalSince(sunrise)
        guard total > 0 else { return 0 }
        let passed = Date().timeIntervalSince(sunrise)
        return max(0, min(100, (total - passed) / total * 100))
    }

    var isUmbrellaNeeded: Bool {
        hourly.prefix(10).contains { $0.precipitationChance > 0.3 }
    }

    var isSunglassesNeeded: Bool {
        current.uvIndex.value > 2
    }
}
#endif
