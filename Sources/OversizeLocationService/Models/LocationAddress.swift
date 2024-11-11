//
// Copyright © 2022 Alexander Romanov
// LocationAddress.swift
//

import Foundation
import MapKit
import OversizeCore

public struct LocationAddress: Codable, @unchecked Sendable {
    public let streetNumber: String // eg. 1
    public let streetName: String // eg. Infinite Loop
    public let city: String // eg. Cupertino
    public let state: String // eg. CA
    public let zipCode: String // eg. 95014
    public let country: String // eg. United States
    public let isoCountryCode: String // eg. US

    public var address: String {
        "\(streetName) \(streetNumber)"
    }

    public var formattedAddress: String {
        """
        \(streetName) \(streetNumber),
        \(city), \(state) \(zipCode)
        \(country)
        """
    }

    public enum CardKeys: CodingKey, Sendable {
        case streetNumber
        case streetName
        case city
        case state
        case zipCode
        case country
        case isoCountryCode
    }

    public init(with placemark: CLPlacemark) {
        streetName = placemark.thoroughfare.valueOrEmpty
        streetNumber = placemark.subThoroughfare.valueOrEmpty
        city = placemark.locality.valueOrEmpty
        state = placemark.administrativeArea.valueOrEmpty
        zipCode = placemark.postalCode.valueOrEmpty
        country = placemark.country.valueOrEmpty
        isoCountryCode = placemark.isoCountryCode.valueOrEmpty
    }
}
