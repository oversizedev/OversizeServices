// Copyright © 2026 Alexander Romanov
// WeatherKitExtensions.swift

#if canImport(WeatherKit)
import Foundation
import WeatherKit

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
extension WeatherCondition {
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

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
extension MoonPhase {
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

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
extension DayWeather: @retroactive Identifiable {
    public var id: Date {
        date
    }
}

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
extension HourWeather: @retroactive Identifiable {
    public var id: Date {
        date
    }
}

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
public extension CurrentWeather {
    var feelsLike: Measurement<UnitTemperature> {
        apparentTemperature
    }

    var windSpeed: Measurement<UnitSpeed> {
        wind.speed
    }

    var windGust: Measurement<UnitSpeed>? {
        wind.gust
    }

    var windDirection: Double {
        wind.direction.converted(to: .degrees).value
    }

    var conditionDescription: String {
        condition.weatherDescription
    }
}

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
public extension DayWeather {
    var conditionDescription: String {
        condition.weatherDescription
    }

    var moonPhase: Double {
        moon.phase.normalizedValue
    }

    var sunrise: Date? {
        sun.sunrise
    }

    var sunset: Date? {
        sun.sunset
    }

    var windSpeed: Measurement<UnitSpeed> {
        wind.speed
    }

    var windGust: Measurement<UnitSpeed>? {
        wind.gust
    }

    var windDirection: Double {
        wind.direction.converted(to: .degrees).value
    }
}

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
public extension HourWeather {
    var feelsLike: Measurement<UnitTemperature> {
        apparentTemperature
    }

    var conditionDescription: String {
        condition.weatherDescription
    }

    var windSpeed: Measurement<UnitSpeed> {
        wind.speed
    }

    var windDirection: Double {
        wind.direction.converted(to: .degrees).value
    }
}
#endif
