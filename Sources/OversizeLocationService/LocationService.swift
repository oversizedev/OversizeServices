//
// Copyright © 2022 Alexander Romanov
// LocationService.swift
//

import CoreLocation
import Foundation
import MapKit

public protocol LocationServiceProtocol {
    func currentLocation() async throws -> CLLocationCoordinate2D
    func permissionsStatus() -> CLAuthorizationStatus
    // func currentCity() async throws -> String
}

public class LocationService: NSObject, ObservableObject {
    private typealias LocationCheckedThrowingContinuation = CheckedContinuation<CLLocationCoordinate2D, Error>
    // private typealias CityCheckedThrowingContinuation = CheckedContinuation<String, Error>

    fileprivate lazy var locationManager = CLLocationManager()

    private var locationCheckedThrowingContinuation: LocationCheckedThrowingContinuation?
    // private var cityCheckedThrowingContinuation: CityCheckedThrowingContinuation?
}

extension LocationService: CLLocationManagerDelegate {
    public func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let locationObj = locations.last {
            // Location
            let coord = locationObj.coordinate
            let location = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
            locationCheckedThrowingContinuation?.resume(returning: location)
            locationCheckedThrowingContinuation = nil

            // City name
//            let geocoder = CLGeocoder()
//            geocoder.reverseGeocodeLocation(locationObj) { [weak self] placemarks, _ in
            ////                if let error = error {
            ////                    self?.cityCheckedThrowingContinuation?.resume(throwing: error)
            ////                    self?.cityCheckedThrowingContinuation = nil
            ////                }
//
//                if let firstLocation = placemarks?[0], let cityName = firstLocation.locality {
//                    self?.cityCheckedThrowingContinuation?.resume(returning: cityName)
//                    self?.cityCheckedThrowingContinuation = nil
//                }
//            }
        }
    }

    public func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        locationCheckedThrowingContinuation?.resume(throwing: error)
        locationCheckedThrowingContinuation = nil

//        cityCheckedThrowingContinuation?.resume(throwing: error)
//        cityCheckedThrowingContinuation = nil
    }
}

extension LocationService: LocationServiceProtocol {
//    public func currentCity() async throws -> String {
//        try await withCheckedThrowingContinuation { [weak self] (continuation: CityCheckedThrowingContinuation) in
//            guard let self = self else {
//                return
//            }
//
//            self.cityCheckedThrowingContinuation = continuation
//
//            self.locationManager.delegate = self
//            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
//            self.locationManager.requestWhenInUseAuthorization()
//            self.locationManager.startUpdatingLocation()
//        }
//    }

    public func currentLocation() async throws -> CLLocationCoordinate2D {
        try await withCheckedThrowingContinuation { [weak self] (continuation: LocationCheckedThrowingContinuation) in
            guard let self else {
                return
            }

            self.locationCheckedThrowingContinuation = continuation

            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.startUpdatingLocation()
        }
    }

    public func permissionsStatus() -> CLAuthorizationStatus {
        locationManager.requestWhenInUseAuthorization()
        return locationManager.authorizationStatus
    }

//    public func requestAuthorizationWhenInUse() async -> CLAuthorizationStatus {
//
//            await withCheckedContinuation { continuation in
//                let authorizationStatus = permissionsStatus()
//                if authorizationStatus != .notDetermined {
//                    continuation.resume(with: .success(authorizationStatus))
//                } else {
//                    authorizationPerformer.linkContinuation(continuation)
//                    proxyDelegate.addPerformer(authorizationPerformer)
//                    locationManager.requestWhenInUseAuthorization()
//                }
//            }
//
//    }
}
