//
//  LocationService.swift
//  Seasonal
//
//  Created by Clint Thomas on 6/8/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//

import CoreLocation

final class LocationService: NSObject {

    weak var locationDelegate: LocationDelegate?

    private let locationManager = CLLocationManager()

    init(delegate: LocationDelegate) {
        locationDelegate = delegate
        super.init()

        locationManager.desiredAccuracy = kCLLocationAccuracyReduced
        locationManager.distanceFilter = kCLLocationAccuracyThreeKilometers
        locationManager.delegate = self
    }

    private func stop() {
        locationManager.stopUpdatingLocation()
        locationDelegate?.locationReady(location: nil)
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            stop()
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let mostRecentLocation = locations.last else { return }
        locationDelegate?.locationReady(location: mostRecentLocation)
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        stop()
#if DEBUG
        print("Location not found \(error) - Use generalized Australian data")
#endif
    }
}
