//
// Copyright © 2022 Alexander Romanov
// LocationService.swift
//

import CoreLocation
import Foundation
import MapKit
import OversizeCore

public protocol LocationServiceProtocol: Sendable {
    func currentLocation() async throws -> CLLocationCoordinate2D?
    func systemPermissionsStatus() -> CLAuthorizationStatus
    func permissionsStatus() -> Result<Bool, Error>
    func fetchCoordinateFromAddress(_ address: String) async throws -> CLLocationCoordinate2D
    func fetchAddressFromLocation(_ location: CLLocationCoordinate2D) async throws -> LocationAddress
}

public final class LocationService: NSObject, @unchecked Sendable {
    private lazy var locationManager = CLLocationManager()
    private let continuationLock = NSLock()
    private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D?, Error>?

    override init() {
        super.init()
        locationManager.delegate = self
    }
}

private extension LocationService {
    func replaceLocationContinuation(with continuation: CheckedContinuation<CLLocationCoordinate2D?, Error>) {
        continuationLock.lock()
        let previousContinuation = locationContinuation
        locationContinuation = continuation
        continuationLock.unlock()

        previousContinuation?.resume(throwing: CancellationError())
    }

    func takeLocationContinuation() -> CheckedContinuation<CLLocationCoordinate2D?, Error>? {
        continuationLock.lock()
        defer { continuationLock.unlock() }
        let continuation = locationContinuation
        locationContinuation = nil
        return continuation
    }
}

extension LocationService: LocationServiceProtocol {
    public func currentLocation() async throws -> CLLocationCoordinate2D? {
        try await withTaskCancellationHandler(operation: {
            try await withCheckedThrowingContinuation { continuation in
                self.replaceLocationContinuation(with: continuation)
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                self.locationManager.requestWhenInUseAuthorization()
                self.locationManager.requestLocation()
            }
        }, onCancel: {
            self.locationManager.stopUpdatingLocation()
            self.takeLocationContinuation()?.resume(throwing: CancellationError())
        })
    }

    public func systemPermissionsStatus() -> CLAuthorizationStatus {
        locationManager.requestWhenInUseAuthorization()
        return locationManager.authorizationStatus
    }

    public func permissionsStatus() -> Result<Bool, Error> {
        locationManager.requestWhenInUseAuthorization()
        switch locationManager.authorizationStatus {
        case .notDetermined:
            return .failure(LocationError.permissionNotDetermined)
        case .denied:
            return .failure(LocationError.accessDenied)
        case .restricted, .authorizedAlways, .authorizedWhenInUse:
            return .success(true)
        @unknown default:
            return .failure(LocationError.unknown(nil))
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
        guard let locationObj = locations.last else {
            takeLocationContinuation()?.resume(returning: nil)
            return
        }

        let coord = locationObj.coordinate
        let location = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
        takeLocationContinuation()?.resume(returning: location)
    }

    public func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        takeLocationContinuation()?.resume(throwing: error)
    }

    /*
     public func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
         locationContinuation?.resume(returning: locations.last?.coordinate)
     }
      */
}
