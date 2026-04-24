// Copyright © 2026 Alexander Romanov
// WeatherData.swift

#if canImport(WeatherKit)
import Foundation
import WeatherKit

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
public struct WeatherData: Sendable {
    public let date: Date
    public let highTemperature: Measurement<UnitTemperature>
    public let lowTemperature: Measurement<UnitTemperature>
    public let symbolName: String
    public let conditionDescription: String
    public let precipitationChance: Double
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
extension WeatherData {
    init(from day: DayWeather) {
        date = day.date
        highTemperature = day.highTemperature
        lowTemperature = day.lowTemperature
        symbolName = day.symbolName
        precipitationChance = day.precipitationChance
        conditionDescription = day.condition.weatherDescription
    }
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
private extension WeatherCondition {
    var weatherDescription: String {
        switch self {
        case .blizzard: "Blizzard"
        case .blowingDust: "Blowing Dust"
        case .blowingSnow: "Blowing Snow"
        case .breezy: "Breezy"
        case .clear: "Clear"
        case .cloudy: "Cloudy"
        case .drizzle: "Drizzle"
        case .flurries: "Flurries"
        case .foggy: "Foggy"
        case .freezingDrizzle: "Freezing Drizzle"
        case .freezingRain: "Freezing Rain"
        case .frigid: "Frigid"
        case .hail: "Hail"
        case .haze: "Hazy"
        case .heavyRain: "Heavy Rain"
        case .heavySnow: "Heavy Snow"
        case .hot: "Hot"
        case .hurricane: "Hurricane"
        case .isolatedThunderstorms: "Isolated Thunderstorms"
        case .mostlyClear: "Mostly Clear"
        case .mostlyCloudy: "Mostly Cloudy"
        case .partlyCloudy: "Partly Cloudy"
        case .rain: "Rain"
        case .scatteredThunderstorms: "Scattered Thunderstorms"
        case .sleet: "Sleet"
        case .smoky: "Smoky"
        case .snow: "Snow"
        case .strongStorms: "Strong Storms"
        case .sunFlurries: "Sun Flurries"
        case .sunShowers: "Sun Showers"
        case .thunderstorms: "Thunderstorms"
        case .tropicalStorm: "Tropical Storm"
        case .windy: "Windy"
        case .wintryMix: "Wintry Mix"
        default: "Unknown"
        }
    }
}
#endif
