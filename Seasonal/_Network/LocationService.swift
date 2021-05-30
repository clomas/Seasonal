//
//  LocationService.swift
//  Seasonal
//
//  Created by Clint Thomas on 6/8/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//

import Foundation
import CoreLocation

enum StateLocation: String, CaseIterable {

    case noState = "aus"
    case westernAustralia = "wa"
    case southAustralia = "sa"
    case northernTerritory = "nt"
    case newSouthWales = "nsw"
    case victoria = "vic"
    case tasmania = "tas"
	case queensland = "qld"
    case act

	func fullName() -> String {
		switch self {
		case .westernAustralia: return "Western Australia"
		case .southAustralia: return "South Australia"
		case .northernTerritory: return "Northern Territory"
		case .newSouthWales: return "New South Wales"
		case .victoria: return "Victoria"
		case .tasmania: return "Tasmania"
		case .queensland: return "Queensland"
		default:
			return "Error"
		}
	}
}

protocol LocationDelegate {
    func locationReady(location: StateLocation)
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let sharedInstance = LocationManager()
    private let locationManager: CLLocationManager
    private let locationInfo = LocationInformation()
	weak var locationDelegate: LocationDelegate?
	var authStatus: CLAuthorizationStatus?

    override init() {
        locationManager = CLLocationManager()
        if #available(iOS 14.0, *) {
            locationManager.desiredAccuracy = kCLLocationAccuracyReduced
        }
        locationManager.distanceFilter = kCLLocationAccuracyThreeKilometers
        super.init()
        locationManager.delegate = self
		start()
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
        locationDelegate?.locationReady(location: StateLocation.noState)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let mostRecentLocation = locations.last else {
            return
        }
        // now fill address as well for complete information through lat long ..
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(mostRecentLocation) { (placemarks, _) in
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

    private func parseLocation() {
        var stateFound = StateLocation.noState
        print("location found - \(locationInfo.state ?? StateLocation.noState.rawValue)")

        if let state = locationInfo.state?.lowercased() {
            if state == StateLocation.act.rawValue {
                stateFound = StateLocation.newSouthWales
            } else if state == "ca" {
                stateFound = StateLocation.noState
            } else {
				if locationInfo.country != Constants.straya {
					if let state = StateLocation.init(rawValue: StateLocation.noState.rawValue) {
						stateFound = state
					}
				} else if state != "" {
                    stateFound = StateLocation.init(rawValue: state)!
                }
            }
        }
        locationManager.stopUpdatingLocation()
        locationDelegate?.locationReady(location: stateFound)
    }

    // MARK: Location Updated

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		authStatus = status
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
        print("Location not found \(error) - Use generalized Australian data")
        locationManager.stopUpdatingLocation()
		locationDelegate?.locationReady(location: .noState)
    }
}

class LocationInformation {

    var state: String?
    var country: String?
    var locationFound: Bool?

	init(state: String? = "", country: String? = Constants.straya, locationFound: Bool? = false) {
        self.state = state
        self.country = country
        self.locationFound = locationFound
    }
}
