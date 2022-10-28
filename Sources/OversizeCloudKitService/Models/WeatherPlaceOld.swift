//
// Copyright © 2022 Alexander Romanov
// WeatherPlaceOld.swift
//

// import CloudKit
// import CoreLocation
// import Foundation
// import MapKit
//
// public struct WeatherPlace: Identifiable, Equatable {
//    public var id: String { recordId?.recordName ?? UUID().uuidString }
//    public let name: String
//    public let icon: String
//    public let location: CLLocation
//    public let cityReference: CKRecord.Reference?
//    public var recordId: CKRecord.ID?
//    public let recordType = CloudKitSheme.place.rawValue
//
//    public init(recordId: CKRecord.ID? = nil,
//                name: String,
//                icon: String,
//                location: CLLocation,
//                cityReference: CKRecord.Reference? = nil)
//    {
//        self.name = name
//        self.icon = icon
//        self.location = location
//        self.recordId = recordId
//        self.cityReference = cityReference
//    }
//
//    public init(record: CKRecord) {
//        self.init(recordId: record.recordID,
//                  name: record.value(forKey: "name") as? String ?? "",
//                  icon: record.value(forKey: "icon") as? String ?? "",
//                  location: record.value(forKey: "location") as? CLLocation ?? CLLocation(latitude: 0, longitude: 0),
//                  cityReference: record.value(forKey: CloudKitSheme.city.rawValue) as? CKRecord.Reference)
//    }
// }
