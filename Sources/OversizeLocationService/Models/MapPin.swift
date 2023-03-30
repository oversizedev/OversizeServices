//
// Copyright © 2023 Alexander Romanov
// MapPin.swift
//

import Foundation
import MapKit

public struct MapPoint: Identifiable {
    public let id: UUID
    public let name: String
    public let coordinate: CLLocationCoordinate2D

    public init(id: UUID = UUID(), name: String, coordinate: CLLocationCoordinate2D) {
        self.id = id
        self.name = name
        self.coordinate = coordinate
    }
}
