//
// Copyright © 2022 Alexander Romanov
// WeatherCityOld.swift
//

// import CloudKit
// import Foundation
//
//
//
// public struct WeatherCity: Identifiable {
//    public var id: String { recordId?.recordName ?? UUID().uuidString }
//    public let name: String
//    public let country: String
//    public let latitude: Double
//    public let longitude: Double
//    public let cityId: Int
//    public let position: Int
//    public var places: [WeatherPlace]?
//
//    public var recordId: CKRecord.ID?
//    public let recordType = CloudKitSheme.city.rawValue
//
//    public init(recordId: CKRecord.ID? = nil,
//                name: String, country: String,
//                latitude: Double,
//                longitude: Double,
//                cityId: Int,
//                position: Int,
//                places: [WeatherPlace]? = nil)
//
//    {
//        self.recordId = recordId
//        self.name = name
//        self.country = country
//        self.latitude = latitude
//        self.longitude = longitude
//        self.cityId = cityId
//        self.position = position
//        self.places = places
//    }
//
//    public init(record: CKRecord) {
//        self.init(recordId: record.recordID,
//                  name: record.value(forKey: "name") as? String ?? "",
//                  country: record.value(forKey: "country") as? String ?? "",
//                  latitude: record.value(forKey: "latitude") as? Double ?? 0,
//                  longitude: record.value(forKey: "longitude") as? Double ?? 0,
//                  cityId: record.value(forKey: "cityId") as? Int ?? 0,
//                  position: record.value(forKey: "position") as? Int ?? 0)
//    }
// }
