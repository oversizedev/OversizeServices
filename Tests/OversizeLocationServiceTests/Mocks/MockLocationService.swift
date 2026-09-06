//
// Copyright © 2026 Alexander Romanov
// MockLocationService.swift
//

import CoreLocation
import Foundation
import OversizeCore
import OversizeLocationService

final class MockLocationService: LocationServiceProtocol {
    private let coordinate: CLLocationCoordinate2D
    private let status: CLAuthorizationStatus
    private let address: LocationAddress?

    init(
        coordinate: CLLocationCoordinate2D = .init(latitude: 0, longitude: 0),
        status: CLAuthorizationStatus = .authorizedAlways,
        address: LocationAddress? = nil,
    ) {
        self.coordinate = coordinate
        self.status = status
        self.address = address
    }

    func currentLocation() async throws -> CLLocationCoordinate2D? {
        coordinate
    }

    func systemPermissionsStatus() -> CLAuthorizationStatus {
        status
    }

    func permissionsStatus() -> Result<Bool, Error> {
        status == .denied ? .failure(LocationError.accessDenied) : .success(true)
    }

    func fetchCoordinateFromAddress(_: String) async throws -> CLLocationCoordinate2D {
        coordinate
    }

    func fetchAddressFromLocation(_: CLLocationCoordinate2D) async throws -> LocationAddress {
        guard let address else { throw LocationError.unknown(nil) }
        return address
    }
}
