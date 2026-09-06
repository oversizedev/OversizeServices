//
// Copyright © 2026 Alexander Romanov
// LocationAddressTests.swift
//

import CoreLocation
import Foundation
import MapKit
@testable import OversizeLocationService
import Testing

struct LocationAddressTests {
    private func makeAddress(
        streetNumber: String = "1",
        streetName: String = "Infinite Loop",
        city: String = "Cupertino",
        state: String = "CA",
        zipCode: String = "95014",
        country: String = "United States",
        isoCountryCode: String = "US",
    ) throws -> LocationAddress {
        let json = """
        {
            "streetNumber": "\(streetNumber)",
            "streetName": "\(streetName)",
            "city": "\(city)",
            "state": "\(state)",
            "zipCode": "\(zipCode)",
            "country": "\(country)",
            "isoCountryCode": "\(isoCountryCode)"
        }
        """
        return try JSONDecoder().decode(LocationAddress.self, from: Data(json.utf8))
    }

    @Test
    func addressCombinesStreetNameAndNumber() throws {
        let address = try makeAddress()

        #expect(address.address == "Infinite Loop 1")
    }

    @Test
    func formattedAddressContainsAllComponents() throws {
        let address = try makeAddress()

        #expect(address.formattedAddress == """
        Infinite Loop 1,
        Cupertino, CA 95014
        United States
        """)
    }

    @Test
    func codableRoundTripPreservesValues() throws {
        let address = try makeAddress()

        let data = try JSONEncoder().encode(address)
        let decoded = try JSONDecoder().decode(LocationAddress.self, from: data)

        #expect(decoded.streetNumber == address.streetNumber)
        #expect(decoded.streetName == address.streetName)
        #expect(decoded.city == address.city)
        #expect(decoded.state == address.state)
        #expect(decoded.zipCode == address.zipCode)
        #expect(decoded.country == address.country)
        #expect(decoded.isoCountryCode == address.isoCountryCode)
    }

    @Test
    func placemarkWithoutAddressProducesEmptyComponents() {
        let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0))

        let address = LocationAddress(with: placemark)

        #expect(address.streetNumber.isEmpty)
        #expect(address.streetName.isEmpty)
        #expect(address.city.isEmpty)
        #expect(address.state.isEmpty)
        #expect(address.zipCode.isEmpty)
        #expect(address.country.isEmpty)
        #expect(address.isoCountryCode.isEmpty)
    }
}
