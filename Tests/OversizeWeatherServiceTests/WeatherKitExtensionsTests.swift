//
// Copyright © 2026 Alexander Romanov
// WeatherKitExtensionsTests.swift
//

#if canImport(WeatherKit)
import FactoryKit
import FactoryTesting
import Foundation
@testable import OversizeWeatherService
import Testing
import WeatherKit

struct WeatherKitExtensionsTests {
    @Test
    func weatherConditionDescriptions() {
        guard #available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *) else { return }

        let expectations: [(WeatherCondition, String)] = [
            (.blizzard, "Blizzard"),
            (.clear, "Clear"),
            (.cloudy, "Cloudy"),
            (.haze, "Hazy"),
            (.heavyRain, "Heavy Rain"),
            (.isolatedThunderstorms, "Isolated Thunderstorms"),
            (.mostlyClear, "Mostly Clear"),
            (.partlyCloudy, "Partly Cloudy"),
            (.sunShowers, "Sun Showers"),
            (.wintryMix, "Wintry Mix"),
        ]

        for (condition, expected) in expectations {
            #expect(condition.weatherDescription == expected)
        }
    }

    @Test
    func everyKnownConditionHasDescription() {
        guard #available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *) else { return }

        for condition in WeatherCondition.allCases {
            #expect(condition.weatherDescription.isEmpty == false)
        }
    }

    @Test
    func moonPhaseNormalizedValues() {
        guard #available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *) else { return }

        let expectations: [(MoonPhase, Double)] = [
            (.new, 0.0),
            (.waxingCrescent, 0.125),
            (.firstQuarter, 0.25),
            (.waxingGibbous, 0.375),
            (.full, 0.5),
            (.waningGibbous, 0.625),
            (.lastQuarter, 0.75),
            (.waningCrescent, 0.875),
        ]

        for (phase, expected) in expectations {
            #expect(phase.normalizedValue == expected)
        }
    }

    @Test
    func moonPhaseValuesAreOrderedWithinCycle() {
        guard #available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *) else { return }

        let phases: [MoonPhase] = [
            .new, .waxingCrescent, .firstQuarter, .waxingGibbous,
            .full, .waningGibbous, .lastQuarter, .waningCrescent,
        ]

        let values = phases.map(\.normalizedValue)

        #expect(values == values.sorted())
        #expect(values.allSatisfy { $0 >= 0 && $0 < 1 })
    }

    @Test(.container)
    func weatherServiceUsesUniqueScope() {
        guard #available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *) else { return }

        #expect(Container.shared.weatherService() !== Container.shared.weatherService())
    }
}
#endif
