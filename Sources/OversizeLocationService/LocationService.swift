//
// Copyright © 2022 Alexander Romanov
// LocationService.swift
//

import CoreLocation
import Foundation
import MapKit
import OversizeModels

public protocol LocationServiceProtocol {
    func currentLocation() async throws -> CLLocationCoordinate2D?
    func systemPermissionsStatus() -> CLAuthorizationStatus
    func permissionsStatus() -> Result<Bool, AppError>
    func fetchCoordinateFromAddress(_ address: String) async throws -> CLLocationCoordinate2D
    func fetchAddressFromLocation(_ location: CLLocationCoordinate2D) async throws -> LocationAddress
}

public final class LocationService: NSObject, @unchecked Sendable {
    private lazy var locationManager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D?, Error>?

    override init() {
        super.init()
        locationManager.delegate = self
    }
}

extension LocationService: LocationServiceProtocol {
    public func currentLocation() async throws -> CLLocationCoordinate2D? {
        try await withTaskCancellationHandler(operation: {
            try await withCheckedThrowingContinuation { continuation in
                self.locationContinuation = continuation
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                self.locationManager.requestWhenInUseAuthorization()
                self.locationManager.requestLocation()
            }
        }, onCancel: {
            #if os(iOS)
                self.locationManager.stopUpdatingHeading()
            #endif
        })
    }

    public func systemPermissionsStatus() -> CLAuthorizationStatus {
        locationManager.requestWhenInUseAuthorization()
        return locationManager.authorizationStatus
    }

    public func permissionsStatus() -> Result<Bool, AppError> {
        locationManager.requestWhenInUseAuthorization()
        switch locationManager.authorizationStatus {
        case .notDetermined:
            return .failure(.location(type: .notDetermined))
        case .denied:
            return .failure(.location(type: .notAccess))
        case .restricted, .authorizedAlways, .authorizedWhenInUse:
            return .success(true)
        @unknown default:
            return .failure(.location(type: .unknown))
        }
    }

    public func fetchCoordinateFromAddress(_ address: String) async throws -> CLLocationCoordinate2D {
        let geocoder = CLGeocoder()

        guard let location = try await geocoder.geocodeAddressString(address)
            .compactMap({ $0.location })
            .first(where: { $0.horizontalAccuracy >= 0 })
        else {
            throw CLError(.geocodeFoundNoResult)
        }

        return location.coordinate
    }

    public func fetchAddressFromLocation(_ location: CLLocationCoordinate2D) async throws -> LocationAddress {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let placemarks = try await geocoder.reverseGeocodeLocation(location)
        if let placemark = placemarks.first {
            return LocationAddress(with: placemark)
        } else {
            throw CLError(.geocodeFoundNoResult)
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    public func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let locationObj = locations.last {
            // Location
            let coord = locationObj.coordinate
            let location = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
            locationContinuation?.resume(returning: location)
            locationContinuation = nil
        }
    }

    public func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(throwing: error)
    }

    /*
     public func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
         locationContinuation?.resume(returning: locations.last?.coordinate)
     }
      */
}
