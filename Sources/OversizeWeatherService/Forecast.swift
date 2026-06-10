// Copyright © 2026 Alexander Romanov
// Forecast.swift

#if canImport(WeatherKit)
import Foundation

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
public struct Forecast: Sendable {
    public let current: CurrentForecast
    public let hourly: [HourForecast]
    public let daily: [DayForecast]

    public init(current: CurrentForecast, hourly: [HourForecast], daily: [DayForecast]) {
        self.current = current
        self.hourly = hourly
        self.daily = daily
    }
}

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
public extension Forecast {
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
        current.uvIndex > 2
    }
}
#endif
