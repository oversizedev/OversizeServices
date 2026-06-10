// Copyright © 2026 Alexander Romanov
// HourForecast.swift

#if canImport(WeatherKit)
import Foundation
import WeatherKit

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
public struct HourForecast: Sendable, Identifiable {
    public var id: Date {
        date
    }

    public let date: Date
    public let temperature: Measurement<UnitTemperature>
    public let feelsLike: Measurement<UnitTemperature>
    public let humidity: Double
    public let precipitationChance: Double
    public let precipitationAmount: Measurement<UnitLength>
    public let symbolName: String
    public let conditionDescription: String
    public let isDaylight: Bool
    public let windSpeed: Measurement<UnitSpeed>
    public let windDirection: Double
    public let uvIndex: Int
    public let cloudCover: Double
    public let visibility: Measurement<UnitLength>

    public init(
        date: Date,
        temperature: Measurement<UnitTemperature>,
        feelsLike: Measurement<UnitTemperature>,
        humidity: Double,
        precipitationChance: Double,
        precipitationAmount: Measurement<UnitLength>,
        symbolName: String,
        conditionDescription: String,
        isDaylight: Bool,
        windSpeed: Measurement<UnitSpeed>,
        windDirection: Double,
        uvIndex: Int,
        cloudCover: Double,
        visibility: Measurement<UnitLength>,
    ) {
        self.date = date
        self.temperature = temperature
        self.feelsLike = feelsLike
        self.humidity = humidity
        self.precipitationChance = precipitationChance
        self.precipitationAmount = precipitationAmount
        self.symbolName = symbolName
        self.conditionDescription = conditionDescription
        self.isDaylight = isDaylight
        self.windSpeed = windSpeed
        self.windDirection = windDirection
        self.uvIndex = uvIndex
        self.cloudCover = cloudCover
        self.visibility = visibility
    }
}

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
extension HourForecast {
    init(from hour: HourWeather) {
        date = hour.date
        temperature = hour.temperature
        feelsLike = hour.apparentTemperature
        humidity = hour.humidity
        precipitationChance = hour.precipitationChance
        precipitationAmount = hour.precipitationAmount
        symbolName = hour.symbolName
        conditionDescription = hour.condition.weatherDescription
        isDaylight = hour.isDaylight
        windSpeed = hour.wind.speed
        windDirection = hour.wind.direction.converted(to: .degrees).value
        uvIndex = hour.uvIndex.value
        cloudCover = hour.cloudCover
        visibility = hour.visibility
    }
}
#endif
