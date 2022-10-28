//
// Copyright © 2022 Alexander Romanov
// WeatherCity.swift
//

import CloudKit
import Foundation

public struct WeatherCity: Identifiable {
    public let name: String
    public let country: String
    public let location: CLLocation
    public let cityId: Int
    public let position: Int

    // MARK: - Sourcery generated

    public var recordId: CKRecord.ID?
    public var id: String { recordId?.recordName ?? UUID().uuidString }

    public enum WeatherCityRecordKeys: String {
        case type = "WeatherCity"
        case name
        case country
        case location
        case cityId
        case position
    }

    public init(recordId: CKRecord.ID? = nil, name: String, country: String, location: CLLocation, cityId: Int, position: Int) {
        self.recordId = recordId
        self.name = name
        self.country = country
        self.location = location
        self.cityId = cityId
        self.position = position
    }

    var record: CKRecord {
        let record = CKRecord(recordType: WeatherCityRecordKeys.type.rawValue)
        record[WeatherCityRecordKeys.name.rawValue] = name
        record[WeatherCityRecordKeys.country.rawValue] = country
        record[WeatherCityRecordKeys.location.rawValue] = location
        record[WeatherCityRecordKeys.cityId.rawValue] = cityId
        record[WeatherCityRecordKeys.position.rawValue] = position
        return record
    }

    init?(from record: CKRecord) {
        guard
            let name = record[WeatherCityRecordKeys.name.rawValue] as? String,
            let country = record[WeatherCityRecordKeys.country.rawValue] as? String,
            let location = record[WeatherCityRecordKeys.location.rawValue] as? CLLocation,
            let cityId = record[WeatherCityRecordKeys.cityId.rawValue] as? Int,
            let position = record[WeatherCityRecordKeys.position.rawValue] as? Int
        else { return nil }
        self = .init(recordId: record.recordID,
                     name: name,
                     country: country,
                     location: location,
                     cityId: cityId,
                     position: position)
    }
}
