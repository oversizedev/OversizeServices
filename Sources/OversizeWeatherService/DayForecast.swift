// Copyright © 2026 Alexander Romanov
// DayForecast.swift

#if canImport(WeatherKit)
import Foundation
import WeatherKit

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
public struct DayForecast: Sendable, Identifiable {
    public var id: Date {
        date
    }

    public let date: Date
    public let highTemperature: Measurement<UnitTemperature>
    public let lowTemperature: Measurement<UnitTemperature>
    public let symbolName: String
    public let conditionDescription: String
    public let precipitationChance: Double
    public let precipitationAmount: Measurement<UnitLength>
    public let snowfallAmount: Measurement<UnitLength>
    public let rainfallAmount: Measurement<UnitLength>
    public let uvIndex: Int
    public let sunrise: Date?
    public let sunset: Date?
    public let moonPhase: Double
    public let windSpeed: Measurement<UnitSpeed>
    public let windDirection: Double
    public let windGust: Measurement<UnitSpeed>?

    public init(
        date: Date,
        highTemperature: Measurement<UnitTemperature>,
        lowTemperature: Measurement<UnitTemperature>,
        symbolName: String,
        conditionDescription: String,
        precipitationChance: Double,
        precipitationAmount: Measurement<UnitLength>,
        snowfallAmount: Measurement<UnitLength>,
        rainfallAmount: Measurement<UnitLength>,
        uvIndex: Int,
        sunrise: Date?,
        sunset: Date?,
        moonPhase: Double,
        windSpeed: Measurement<UnitSpeed>,
        windDirection: Double,
        windGust: Measurement<UnitSpeed>?,
    ) {
        self.date = date
        self.highTemperature = highTemperature
        self.lowTemperature = lowTemperature
        self.symbolName = symbolName
        self.conditionDescription = conditionDescription
        self.precipitationChance = precipitationChance
        self.precipitationAmount = precipitationAmount
        self.snowfallAmount = snowfallAmount
        self.rainfallAmount = rainfallAmount
        self.uvIndex = uvIndex
        self.sunrise = sunrise
        self.sunset = sunset
        self.moonPhase = moonPhase
        self.windSpeed = windSpeed
        self.windDirection = windDirection
        self.windGust = windGust
    }
}

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
extension DayForecast {
    init(from day: DayWeather) {
        date = day.date
        highTemperature = day.highTemperature
        lowTemperature = day.lowTemperature
        symbolName = day.symbolName
        conditionDescription = day.condition.weatherDescription
        precipitationChance = day.precipitationChance
        precipitationAmount = day.precipitationAmount
        snowfallAmount = day.snowfallAmount
        rainfallAmount = day.rainfallAmount
        uvIndex = day.uvIndex.value
        sunrise = day.sun.sunrise
        sunset = day.sun.sunset
        moonPhase = day.moon.phase.normalizedValue
        windSpeed = day.wind.speed
        windDirection = day.wind.direction.converted(to: .degrees).value
        windGust = day.wind.gust
    }
}

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
private extension MoonPhase {
    var normalizedValue: Double {
        switch self {
        case .new: 0.0
        case .waxingCrescent: 0.125
        case .firstQuarter: 0.25
        case .waxingGibbous: 0.375
        case .full: 0.5
        case .waningGibbous: 0.625
        case .lastQuarter: 0.75
        case .waningCrescent: 0.875
        @unknown default: 0.0
        }
    }
}
#endif
