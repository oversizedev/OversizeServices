// Copyright © 2026 Alexander Romanov
// CurrentForecast.swift

#if canImport(WeatherKit)
import Foundation
import WeatherKit

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
public struct CurrentForecast: Sendable {
    public let date: Date
    public let temperature: Measurement<UnitTemperature>
    public let feelsLike: Measurement<UnitTemperature>
    public let dewPoint: Measurement<UnitTemperature>
    public let humidity: Double
    public let pressure: Measurement<UnitPressure>
    public let visibility: Measurement<UnitLength>
    public let uvIndex: Int
    public let cloudCover: Double
    public let windSpeed: Measurement<UnitSpeed>
    public let windDirection: Double
    public let windGust: Measurement<UnitSpeed>?
    public let symbolName: String
    public let conditionDescription: String
    public let isDaylight: Bool

    public init(
        date: Date,
        temperature: Measurement<UnitTemperature>,
        feelsLike: Measurement<UnitTemperature>,
        dewPoint: Measurement<UnitTemperature>,
        humidity: Double,
        pressure: Measurement<UnitPressure>,
        visibility: Measurement<UnitLength>,
        uvIndex: Int,
        cloudCover: Double,
        windSpeed: Measurement<UnitSpeed>,
        windDirection: Double,
        windGust: Measurement<UnitSpeed>?,
        symbolName: String,
        conditionDescription: String,
        isDaylight: Bool,
    ) {
        self.date = date
        self.temperature = temperature
        self.feelsLike = feelsLike
        self.dewPoint = dewPoint
        self.humidity = humidity
        self.pressure = pressure
        self.visibility = visibility
        self.uvIndex = uvIndex
        self.cloudCover = cloudCover
        self.windSpeed = windSpeed
        self.windDirection = windDirection
        self.windGust = windGust
        self.symbolName = symbolName
        self.conditionDescription = conditionDescription
        self.isDaylight = isDaylight
    }
}

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
extension CurrentForecast {
    init(from weather: CurrentWeather) {
        date = weather.date
        temperature = weather.temperature
        feelsLike = weather.apparentTemperature
        dewPoint = weather.dewPoint
        humidity = weather.humidity
        pressure = weather.pressure
        visibility = weather.visibility
        uvIndex = weather.uvIndex.value
        cloudCover = weather.cloudCover
        windSpeed = weather.wind.speed
        windDirection = weather.wind.direction.converted(to: .degrees).value
        windGust = weather.wind.gust
        symbolName = weather.symbolName
        conditionDescription = weather.condition.weatherDescription
        isDaylight = weather.isDaylight
    }
}
#endif
