//
// Copyright © 2022 Alexander Romanov
// WeatherDressOld.swift
//

import CloudKit
import Foundation

// public struct WeatherDress: Identifiable {
//    public var id: String { recordId?.recordName ?? UUID().uuidString }
//    public let name: String
//    public let icon: String
//    public let minTemperature: Double
//    public let maxTemperature: Double
//    public let forSunnyWeather: Bool
//    public let forRainyWeather: Bool
//    public let isFavorite: Bool
//    public var recordId: CKRecord.ID?
// }
//
// extension WeatherDress {
//    enum WeatherDressRecordKeys: String {
//        case type = "Dress"
//        case name
//        case icon
//        case minTemperature
//        case maxTemperature
//        case forSunnyWeather
//        case forRainyWeather
//        case isFavorite
//    }
//
//    public init(recordId: CKRecord.ID? = nil,
//                name: String,
//                icon: String,
//                minTemperature: Double,
//                maxTemperature: Double,
//                forSunnyWeather: Bool,
//                forRainyWeather: Bool,
//                isFavorite: Bool) {
//        self.recordId = recordId
//        self.name = name
//        self.icon = icon
//        self.minTemperature = minTemperature
//        self.maxTemperature = maxTemperature
//        self.forSunnyWeather = forSunnyWeather
//        self.forRainyWeather = forRainyWeather
//        self.isFavorite = isFavorite
//    }
// }
//
//
// extension WeatherDress {
//    var record: CKRecord {
//        let record = CKRecord(recordType: WeatherDressRecordKeys.type.rawValue)
//        record[WeatherDressRecordKeys.name.rawValue] = name
//        record[WeatherDressRecordKeys.icon.rawValue] = icon
//        record[WeatherDressRecordKeys.minTemperature.rawValue] = minTemperature
//        record[WeatherDressRecordKeys.maxTemperature.rawValue] = maxTemperature
//        record[WeatherDressRecordKeys.forSunnyWeather.rawValue] = forSunnyWeather
//        record[WeatherDressRecordKeys.forRainyWeather.rawValue] = forRainyWeather
//        record[WeatherDressRecordKeys.isFavorite.rawValue] = isFavorite
//        return record
//    }
// }
//
// extension WeatherDress {
//    init?(from record: CKRecord) {
//        guard
//            let name = record[WeatherDressRecordKeys.name.rawValue] as? String,
//            let icon = record[WeatherDressRecordKeys.icon.rawValue] as? String,
//            let minTemperature = record[WeatherDressRecordKeys.minTemperature.rawValue] as? Double,
//            let maxTemperature = record[WeatherDressRecordKeys.maxTemperature.rawValue] as? Double,
//            let forSunnyWeather = record[WeatherDressRecordKeys.forSunnyWeather.rawValue] as? Bool,
//            let forRainyWeather = record[WeatherDressRecordKeys.forRainyWeather.rawValue] as? Bool,
//            let isFavorite = record[WeatherDressRecordKeys.isFavorite.rawValue] as? Bool
//        else { return nil }
//        self = .init(recordId: record.recordID,
//                     name: name,
//                     icon: icon,
//                     minTemperature: minTemperature,
//                     maxTemperature: maxTemperature,
//                     forSunnyWeather: forSunnyWeather,
//                     forRainyWeather: forRainyWeather,
//                     isFavorite: isFavorite)
//    }
// }
