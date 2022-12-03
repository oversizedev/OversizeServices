//
// Copyright © 2022 Alexander Romanov
// LocationService.swift
//

import CoreLocation
import Foundation
import MapKit

public protocol LocationServiceProtocol {
    func currentLocation() async throws -> CLLocationCoordinate2D?
    func permissionsStatus() -> CLAuthorizationStatus
}

public class LocationService: NSObject, ObservableObject {
    fileprivate lazy var locationManager = CLLocationManager()
    var locationContinuation: CheckedContinuation<CLLocationCoordinate2D?, Error>?

    override init() {
        super.init()
        locationManager.delegate = self
    }
}

extension LocationService: LocationServiceProtocol {
    //  public func currentLocation() async throws -> CLLocationCoordinate2D? {
//      try await withCheckedThrowingContinuation { continuation in
//          self.locationContinuation = continuation
//          locationManager.desiredAccuracy = kCLLocationAccuracyBest
//          locationManager.requestWhenInUseAuthorization()
//          locationManager.requestLocation()
//      }
    //  }

    public func currentLocation() async throws -> CLLocationCoordinate2D? {
        try await withTaskCancellationHandler(operation: {
            try await withCheckedThrowingContinuation { continuation in
                self.locationContinuation = continuation
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                self.locationManager.requestWhenInUseAuthorization()
                self.locationManager.requestLocation()
            }
        }, onCancel: {
            self.locationManager.stopUpdatingHeading()
        })
    }

    public func permissionsStatus() -> CLAuthorizationStatus {
        locationManager.requestWhenInUseAuthorization()
        return locationManager.authorizationStatus
    }
}

extension LocationService: CLLocationManagerDelegate {
    public func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationContinuation?.resume(returning: locations.last?.coordinate)
    }

    public func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(throwing: error)
    }
}
