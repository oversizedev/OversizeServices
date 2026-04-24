// Copyright © 2026 Alexander Romanov
// WeatherService.swift

#if canImport(WeatherKit)
import CoreLocation
import Foundation
import OversizeCore
import WeatherKit

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
public protocol WeatherServiceProtocol: Sendable {
    func fetchWeather(for date: Date, location: CLLocationCoordinate2D) async -> Result<WeatherData, Error>
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
public actor OversizeWeatherService: WeatherServiceProtocol {
    private let service = WeatherKit.WeatherService.shared

    public init() {}

    public func fetchWeather(for date: Date, location: CLLocationCoordinate2D) async -> Result<WeatherData, Error> {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return .failure(OversizeCore.WeatherError.noDataForDate)
        }
        do {
            let forecast = try await service.weather(
                for: .init(latitude: location.latitude, longitude: location.longitude),
                including: .daily(startDate: startOfDay, endDate: endOfDay),
            )
            guard let day = forecast.forecast.first else {
                return .failure(OversizeCore.WeatherError.noDataForDate)
            }
            return .success(WeatherData(from: day))
        } catch {
            logError("Waerther fetch error: \(error.localizedDescription)")
            return .failure(OversizeCore.WeatherError.unknown(error))
        }
    }
}
#endif
