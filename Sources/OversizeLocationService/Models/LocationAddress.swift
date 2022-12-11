//
//  File.swift
//  
//
//  Created by Aleksandr Romanov on 11.12.2022.
//

import Foundation
import MapKit

public struct LocationAddress: Codable {
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

    public enum CardKeys: CodingKey {
        case streetNumber
        case streetName
        case city
        case state
        case zipCode
        case country
        case isoCountryCode
    }

    public init(with placemark: CLPlacemark) {
        streetName = placemark.thoroughfare ?? ""
        streetNumber = placemark.subThoroughfare ?? ""
        city = placemark.locality ?? ""
        state = placemark.administrativeArea ?? ""
        zipCode = placemark.postalCode ?? ""
        country = placemark.country ?? ""
        isoCountryCode = placemark.isoCountryCode ?? ""
    }
}

