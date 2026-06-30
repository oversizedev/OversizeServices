// Copyright © 2026 Alexander Romanov
// WeatherService.swift

#if canImport(WeatherKit)
import CoreLocation
import Foundation
import OversizeCore
import WeatherKit

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
public actor OversizeWeatherService {
    private let service = WeatherKit.WeatherService.shared

    public init() {}

    public func fetchWeather(for date: Date, location: CLLocationCoordinate2D) async -> Result<DayWeather, Error> {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return .failure(WeatherError.noDataForDate)
        }
        do {
            let forecast = try await service.weather(
                for: clLocation(from: location),
                including: .daily(startDate: startOfDay, endDate: endOfDay),
            )
            guard let day = forecast.forecast.first else {
                return .failure(WeatherError.noDataForDate)
            }
            return .success(day)
        } catch {
            Log.error("fetchWeather failed: \(error.localizedDescription)")
            return .failure(WeatherError.unknown(error))
        }
    }

    public func fetchForecast(location: CLLocationCoordinate2D) async -> Result<AppForecast, Error> {
        let now = Date()
        let calendar = Calendar.current
        let hourlyEnd = calendar.date(byAdding: .hour, value: 24, to: now) ?? now
        let dailyEnd = calendar.date(byAdding: .day, value: 10, to: now) ?? now
        do {
            let (current, hourly, daily) = try await service.weather(
                for: clLocation(from: location),
                including: .current,
                .hourly(startDate: now, endDate: hourlyEnd),
                .daily(startDate: now, endDate: dailyEnd),
            )
            return .success(AppForecast(
                current: current,
                hourly: Array(hourly.forecast),
                daily: Array(daily.forecast),
            ))
        } catch {
            Log.error("fetchForecast failed: \(error.localizedDescription)")
            return .failure(WeatherError.unknown(error))
        }
    }

    public func fetchCurrentForecast(location: CLLocationCoordinate2D) async -> Result<CurrentWeather, Error> {
        do {
            let current = try await service.weather(for: clLocation(from: location), including: .current)
            return .success(current)
        } catch {
            Log.error("fetchCurrentForecast failed: \(error.localizedDescription)")
            return .failure(WeatherError.unknown(error))
        }
    }

    public func fetchHourlyForecast(location: CLLocationCoordinate2D, hours: Int) async -> Result<[HourWeather], Error> {
        let now = Date()
        let endDate = Calendar.current.date(byAdding: .hour, value: hours, to: now) ?? now
        do {
            let forecast = try await service.weather(
                for: clLocation(from: location),
                including: .hourly(startDate: now, endDate: endDate),
            )
            return .success(Array(forecast.forecast))
        } catch {
            Log.error("fetchHourlyForecast failed: \(error.localizedDescription)")
            return .failure(WeatherError.unknown(error))
        }
    }

    public func fetchDailyForecast(location: CLLocationCoordinate2D, days: Int) async -> Result<[DayWeather], Error> {
        let now = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: days, to: now) ?? now
        do {
            let forecast = try await service.weather(
                for: clLocation(from: location),
                including: .daily(startDate: now, endDate: endDate),
            )
            return .success(Array(forecast.forecast))
        } catch {
            Log.error("fetchDailyForecast failed: \(error.localizedDescription)")
            return .failure(WeatherError.unknown(error))
        }
    }

    public func fetchDayForecast(for date: Date, location: CLLocationCoordinate2D) async -> Result<DayWeather, Error> {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return .failure(WeatherError.noDataForDate)
        }
        do {
            let forecast = try await service.weather(
                for: clLocation(from: location),
                including: .daily(startDate: startOfDay, endDate: endOfDay),
            )
            guard let day = forecast.forecast.first else {
                return .failure(WeatherError.noDataForDate)
            }
            return .success(day)
        } catch {
            Log.error("fetchDayForecast failed: \(error.localizedDescription)")
            return .failure(WeatherError.unknown(error))
        }
    }

    private func clLocation(from coordinate: CLLocationCoordinate2D) -> CLLocation {
        CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}
#endif
