	//
	//  LocationService.swift
	//  Seasonal
	//
	//  Created by Clint Thomas on 6/8/19.
	//  Copyright © 2019 Clint Thomas. All rights reserved.
	//

import Foundation
import CoreLocation

protocol LocationDelegateOld: AnyObject {
	func locationReady(location: StateLocation)
}

class LocationManagerOld: NSObject, CLLocationManagerDelegate {

	private let locationManager: CLLocationManager
	private let locationInfo: LocationInformation = LocationInformation()

	var authStatus: CLAuthorizationStatus?

	weak var locationDelegate: LocationDelegateOld?

	override init() {
		locationManager = CLLocationManager()
		super.init()

		if #available(iOS 14.0, *) {
			locationManager.desiredAccuracy = kCLLocationAccuracyReduced
		}
		locationManager.distanceFilter = kCLLocationAccuracyThreeKilometers
		locationManager.delegate = self

		start()
	}

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let mostRecentLocation = locations.last else {
			return
		}
			// now fill address as well for complete information through lat long ..
		let geoCoder: CLGeocoder = CLGeocoder()
		geoCoder.reverseGeocodeLocation(mostRecentLocation) { [weak self] (placeMarks: [CLPlacemark]?, _)  in
			guard let placeMarks = placeMarks, let placeMark = placeMarks.first else { return }

			if let state: String = placeMark.administrativeArea, let country: String = placeMark.country {
				self?.locationInfo.state = state
				self?.locationInfo.country = country
				self?.locationInfo.locationFound = true
			} else {
				self?.locationInfo.locationFound = false
			}
			self?.parseLocation()
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
		locationManager.stopUpdatingLocation()
		locationDelegate?.locationReady(location: .noState)

#if DEBUG
		print("Location not found \(error) - Use generalized Australian data")
#endif
	}

		// MARK: Start

	private func start() {

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

		// MARK: Stop

	private func stop() {
		locationManager.stopUpdatingLocation()
		locationDelegate?.locationReady(location: .noState)
	}

		// MARK: States in Aus

	private func parseLocation() {
		var stateFound: StateLocation = .noState

		if let state: String = locationInfo.state?.lowercased() {

			if state == StateLocation.act.rawValue {
				stateFound = StateLocation.newSouthWales
			} else if state == "ca" {
				stateFound = StateLocation.noState
			} else {
				if locationInfo.country != Constants.straya {
					if let state: StateLocation = StateLocation(rawValue: StateLocation.noState.rawValue) {
						stateFound = state
#if DEBUG
						print("location found - \(locationInfo.state ?? StateLocation.noState.rawValue)")
#endif
					}
				} else if state != "" {
					if let locationInit: StateLocation = StateLocation(rawValue: state) {
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
