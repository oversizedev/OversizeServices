//
// Copyright © 2022 Alexander Romanov
// WeatherDress.swift
//

import CloudKit
import Foundation

public struct WeatherDress: Identifiable {
    public let name: String
    public let icon: String
    public let minTemperature: Double
    public let maxTemperature: Double
    public let forSunnyWeather: Bool
    public let forRainyWeather: Bool
    public let forSnowyWeather: Bool
    public let isFavorite: Bool
    public let position: Int

    // MARK: - Sourcery generated

    public var recordId: CKRecord.ID?
    public var id: String { recordId?.recordName ?? UUID().uuidString }

    public enum WeatherDressRecordKeys: String {
        case type = "WeatherDress"
        case name
        case icon
        case minTemperature
        case maxTemperature
        case forSunnyWeather
        case forRainyWeather
        case forSnowyWeather
        case isFavorite
        case position
    }

    public init(recordId: CKRecord.ID? = nil, name: String, icon: String, minTemperature: Double, maxTemperature: Double, forSunnyWeather: Bool, forRainyWeather: Bool, forSnowyWeather: Bool, isFavorite: Bool, position: Int) {
        self.recordId = recordId
        self.name = name
        self.icon = icon
        self.minTemperature = minTemperature
        self.maxTemperature = maxTemperature
        self.forSunnyWeather = forSunnyWeather
        self.forRainyWeather = forRainyWeather
        self.forSnowyWeather = forSnowyWeather
        self.isFavorite = isFavorite
        self.position = position
    }

    var record: CKRecord {
        let record = CKRecord(recordType: WeatherDressRecordKeys.type.rawValue)
        record[WeatherDressRecordKeys.name.rawValue] = name
        record[WeatherDressRecordKeys.icon.rawValue] = icon
        record[WeatherDressRecordKeys.minTemperature.rawValue] = minTemperature
        record[WeatherDressRecordKeys.maxTemperature.rawValue] = maxTemperature
        record[WeatherDressRecordKeys.forSunnyWeather.rawValue] = forSunnyWeather
        record[WeatherDressRecordKeys.forRainyWeather.rawValue] = forRainyWeather
        record[WeatherDressRecordKeys.forSnowyWeather.rawValue] = forSnowyWeather
        record[WeatherDressRecordKeys.isFavorite.rawValue] = isFavorite
        record[WeatherDressRecordKeys.position.rawValue] = position
        return record
    }

    init?(from record: CKRecord) {
        guard
            let name = record[WeatherDressRecordKeys.name.rawValue] as? String,
            let icon = record[WeatherDressRecordKeys.icon.rawValue] as? String,
            let minTemperature = record[WeatherDressRecordKeys.minTemperature.rawValue] as? Double,
            let maxTemperature = record[WeatherDressRecordKeys.maxTemperature.rawValue] as? Double,
            let forSunnyWeather = record[WeatherDressRecordKeys.forSunnyWeather.rawValue] as? Bool,
            let forRainyWeather = record[WeatherDressRecordKeys.forRainyWeather.rawValue] as? Bool,
            let forSnowyWeather = record[WeatherDressRecordKeys.forSnowyWeather.rawValue] as? Bool,
            let isFavorite = record[WeatherDressRecordKeys.isFavorite.rawValue] as? Bool,
            let position = record[WeatherDressRecordKeys.position.rawValue] as? Int
        else { return nil }
        self = .init(recordId: record.recordID,
                     name: name,
                     icon: icon,
                     minTemperature: minTemperature,
                     maxTemperature: maxTemperature,
                     forSunnyWeather: forSunnyWeather,
                     forRainyWeather: forRainyWeather,
                     forSnowyWeather: forSnowyWeather,
                     isFavorite: isFavorite,
                     position: position)
    }
}
