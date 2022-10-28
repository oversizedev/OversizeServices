//
// Copyright © 2022 Alexander Romanov
// WeatherPlace.swift
//

import CloudKit
import CoreLocation
import Foundation
import MapKit

public struct WeatherPlace: Identifiable, Equatable {
    public let name: String
    public let icon: String
    public let location: CLLocation
    public let position: Int

    // MARK: - Sourcery generated

    public var recordId: CKRecord.ID?
    public var id: String { recordId?.recordName ?? UUID().uuidString }

    public enum WeatherPlaceRecordKeys: String {
        case type = "WeatherPlace"
        case name
        case icon
        case location
        case position
    }

    public init(recordId: CKRecord.ID? = nil, name: String, icon: String, location: CLLocation, position: Int) {
        self.recordId = recordId
        self.name = name
        self.icon = icon
        self.location = location
        self.position = position
    }

    var record: CKRecord {
        let record = CKRecord(recordType: WeatherPlaceRecordKeys.type.rawValue)
        record[WeatherPlaceRecordKeys.name.rawValue] = name
        record[WeatherPlaceRecordKeys.icon.rawValue] = icon
        record[WeatherPlaceRecordKeys.location.rawValue] = location
        record[WeatherPlaceRecordKeys.position.rawValue] = position
        return record
    }

    init?(from record: CKRecord) {
        guard
            let name = record[WeatherPlaceRecordKeys.name.rawValue] as? String,
            let icon = record[WeatherPlaceRecordKeys.icon.rawValue] as? String,
            let location = record[WeatherPlaceRecordKeys.location.rawValue] as? CLLocation,
            let position = record[WeatherPlaceRecordKeys.position.rawValue] as? Int
        else { return nil }
        self = .init(recordId: record.recordID,
                     name: name,
                     icon: icon,
                     location: location,
                     position: position)
    }
}
