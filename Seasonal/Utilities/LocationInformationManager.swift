	//
	//  LocationInformationManager.swift
	//  Seasonal
	//
	//  Created by Clint Thomas on 5/7/2025.
	//  Copyright © 2025 Clint Thomas. All rights reserved.
	//

import Foundation
import MapKit

class LocationInformationManager {

	func parseLocation(_ location: CLLocation?) async -> StateLocation {
		guard let location else { return .noState }

		if #available(iOS 26.0, *) {
			let request = MKReverseGeocodingRequest(location: location)
			let placemark: MKPlacemark? = try? await request?.mapItems.first?.placemark

			return parseLocationForDelegate(state: placemark?.administrativeArea, country: placemark?.country)
		} else {
			return .noState
		}
	}

	// MARK: States in Aus

	private func parseLocationForDelegate(state: String?, country: String?) -> StateLocation {
		let lowercaseState: String = state?.lowercased() ?? ""

		var stateFound: StateLocation = .noState

		if lowercaseState == StateLocation.act.rawValue {
			stateFound = StateLocation.newSouthWales
		} else if lowercaseState == "ca" {
			stateFound = StateLocation.noState
		} else {
			if country != Constants.straya {
				if let stateLocation: StateLocation = StateLocation(rawValue: StateLocation.noState.rawValue) {
					stateFound = stateLocation
				}
			} else if lowercaseState != "" {
				if let locationInit: StateLocation = StateLocation(rawValue: lowercaseState) {
					stateFound = locationInit
				}
			}
		}
#if DEBUG
		print("location found - \(String(describing: state))")
#endif
		return stateFound
	}
}
