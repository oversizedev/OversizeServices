//
// Copyright © 2026 Alexander Romanov
// MapPointTests.swift
//

import CoreLocation
import Foundation
@testable import OversizeLocationService
import Testing

struct MapPointTests {
    @Test
    func storesNameAndCoordinate() {
        let coordinate = CLLocationCoordinate2D(latitude: 37.334_886, longitude: -122.008_988)

        let point = MapPoint(name: "Apple Park", coordinate: coordinate)

        #expect(point.name == "Apple Park")
        #expect(point.coordinate.latitude == coordinate.latitude)
        #expect(point.coordinate.longitude == coordinate.longitude)
    }

    @Test
    func generatesUniqueIdentifierByDefault() {
        let coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)

        let first = MapPoint(name: "First", coordinate: coordinate)
        let second = MapPoint(name: "Second", coordinate: coordinate)

        #expect(first.id != second.id)
    }

    @Test
    func usesProvidedIdentifier() {
        let id = UUID()

        let point = MapPoint(id: id, name: "Point", coordinate: .init(latitude: 0, longitude: 0))

        #expect(point.id == id)
    }
}
