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

protocol LocationDelegate: AnyObject {
    func locationReady(location: StateLocation)
}

class LocationManager: NSObject, CLLocationManagerDelegate {

	static let sharedInstance = LocationManager()

	private let locationManager: CLLocationManager
    private let locationInfo = LocationInformation()

	var authStatus: CLAuthorizationStatus?

	weak var locationDelegate: LocationDelegate?

    override init() {
        locationManager = CLLocationManager()
		super.init()

        if #available(iOS 14.0, *) {
            locationManager.desiredAccuracy = kCLLocationAccuracyReduced
        }
        locationManager.distanceFilter = kCLLocationAccuracyThreeKilometers
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

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let mostRecentLocation = locations.last else {
            return
        }
        // now fill address as well for complete information through lat long ..
        let geoCoder = CLGeocoder()
		geoCoder.reverseGeocodeLocation(mostRecentLocation) { (placeMarks, _) in
            guard let placeMarks = placeMarks, let placeMark = placeMarks.first else { return }

            if let state = placeMark.administrativeArea,
                let country = placeMark.country {
                self.locationInfo.state = state
                self.locationInfo.country = country
                self.locationInfo.locationFound = true
            } else {
                self.locationInfo.locationFound = false
            }
            self.parseLocation()
        }
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

	private func stop() {
		locationManager.stopUpdatingLocation()
		locationDelegate?.locationReady(location: StateLocation.noState)
	}

		// MARK: States in Aus

	private func parseLocation() {
		var stateFound = StateLocation.noState

		#if DEBUG
			print(locationInfo.locationFound == true)
		#endif

		if let state = locationInfo.state?.lowercased() {
			if state == StateLocation.act.rawValue {
				stateFound = StateLocation.newSouthWales
			} else if state == "ca" {
				stateFound = StateLocation.noState
			} else {
				if locationInfo.country != Constants.straya {
					if let state = StateLocation.init(rawValue: StateLocation.noState.rawValue) {
						stateFound = state
						print("location found - \(locationInfo.state ?? StateLocation.noState.rawValue)")
					}
				} else if state != "" {
					if let locationInit = StateLocation.init(rawValue: state) {
						stateFound = locationInit
					}
				}
			}
			#if DEBUG
				print("location found - \(locationInfo.state ?? StateLocation.noState.rawValue)")
			#endif
		}
		locationManager.stopUpdatingLocation()
		locationDelegate?.locationReady(location: stateFound)
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
