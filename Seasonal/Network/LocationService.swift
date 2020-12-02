//
//  LocationService.swift
//  Seasonal
//
//  Created by Clint Thomas on 6/8/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//

import Foundation
import CoreLocation

enum State: String {
    case noState = "aus"
    case westernAustralia = "wa"
    case southAustralia = "sa"
    case northernTerritory = "nt"
    case newSouthWales = "nsw"
    case Victoria = "vic"
    case Tasmania = "tas"
    case act
}

protocol LocationDelegate {
    func locationReadyGetData(location: State)
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let instance = LocationManager()
    let locationManager : CLLocationManager
    var locationDelegate: LocationDelegate?
    let locationInfo = LocationInformation()

    override init() {
        locationManager = CLLocationManager()
        if #available(iOS 14.0, *) {
            locationManager.desiredAccuracy = kCLLocationAccuracyReduced
        }
        locationManager.distanceFilter = kCLLocationAccuracyThreeKilometers
        super.init()
        locationManager.delegate = self
    }

    func start() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
                case .notDetermined:
                    locationManager.requestWhenInUseAuthorization()
                    locationManager.startUpdatingLocation()
                case .authorizedAlways, .authorizedWhenInUse:
                    locationManager.startUpdatingLocation()
                default:
                break
            }
        }
    }

    func stop() {
        locationManager.stopUpdatingLocation()
        locationDelegate?.locationReadyGetData(location: State.noState)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let mostRecentLocation = locations.last else {
            return
        }
        // now fill address as well for complete information through lat long ..
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(mostRecentLocation) { (placemarks, error) in
            guard let placemarks = placemarks, let placemark = placemarks.first else { return }
            if let state = placemark.administrativeArea,
                let country = placemark.country {
                self.locationInfo.state = state
                self.locationInfo.country = country
                self.locationInfo.locationFound = true
            } else {
                self.locationInfo.locationFound = false
            }
            self.parseLocation()
        }
    }

    // MARK: States in Aus

    func parseLocation() {
        var stateFound = State.noState
        print("location found - \(locationInfo.state ?? State.noState.rawValue)")

        if let state = locationInfo.state?.lowercased() {
            if state == State.act.rawValue {
                stateFound = State.newSouthWales
            } else if state == "ca" {
                stateFound = State.noState
            }  else {
                if state != "" {
                    stateFound = State.init(rawValue: state)!
                }
                if locationInfo.country != STRAYA {
                    stateFound = State.init(rawValue: State.noState.rawValue)!
                }
            }
        }
        locationManager.stopUpdatingLocation()
        locationDelegate?.locationReadyGetData(location: stateFound)
    }

    // MARK: Location Updated
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) -> Void{
        switch status {
        case .authorizedAlways, .authorizedWhenInUse, .notDetermined:
                locationManager.startUpdatingLocation()
            case .denied, .restricted:
                stop()
            default:
                stop()
        }
    }

    // MARK: Failure

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location not found \(error) - Use generalized Australian data")
        locationManager.stopUpdatingLocation()
    }
}

class LocationInformation {

    var state: String?
    var country: String?
    var locationFound: Bool?

    init(state: String? = "", country: String? = STRAYA, locationFound: Bool? = false) {
        self.state = state
        self.country = country
        self.locationFound = locationFound
    }
}
