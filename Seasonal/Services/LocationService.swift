//
//  LocationService.swift
//  Seasonal
//
//  Created by Clint Thomas on 6/8/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

protocol LocationDelegate: AnyObject {
    func locationReady(location: CLLocation?)
}

enum StateLocation: String, CaseIterable {

    case noState = "aus"
    case act
    case newSouthWales = "nsw"
    case northernTerritory = "nt"
    case queensland = "qld"
    case southAustralia = "sa"
    case tasmania = "tas"
    case victoria = "vic"
    case westernAustralia = "wa"

    var fullName: String {
        switch self {
        case .newSouthWales:  "New South Wales"
        case .northernTerritory:  "Northern Territory"
        case .queensland:  "Queensland"
        case .southAustralia:  "South Australia"
        case .tasmania:  "Tasmania"
        case .victoria:  "Victoria"
        case .westernAustralia:  "Western Australia"
        default:
             "Error"
        }
    }
}

class LocationService: NSObject, CLLocationManagerDelegate {

    private let locationManager: CLLocationManager

    var authStatus: CLAuthorizationStatus?

    weak var locationDelegate: LocationDelegate?

    init(delegate: LocationDelegate) {
        locationDelegate = delegate
        locationManager = CLLocationManager()
        super.init()

        if #available(iOS 14.0, *) {
            locationManager.desiredAccuracy = kCLLocationAccuracyReduced
        }
        locationManager.distanceFilter = kCLLocationAccuracyThreeKilometers
        locationManager.delegate = self
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let mostRecentLocation = locations.last else {
            return
        }

        locationDelegate?.locationReady(location: mostRecentLocation)
        locationManager.stopUpdatingLocation()
    }

    // MARK: Location Updated

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            break
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            stop()
        default:
            stop()
        }
    }

    // MARK: Failure

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        stop()

        #if DEBUG
        print("Location not found \(error) - Use generalized Australian data")
        #endif
    }

    // MARK: Start

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authStatus = manager.authorizationStatus

        switch manager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            stop()
        default:
            break
        }
    }

    // MARK: Stop

    private func stop() {
        locationManager.stopUpdatingLocation()
        locationDelegate?.locationReady(location: nil)
    }
}
