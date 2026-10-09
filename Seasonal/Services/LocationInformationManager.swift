//
//  LocationInformationManager.swift
//  Seasonal
//
//  Created by Clint Thomas on 5/7/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import MapKit

@available(iOS 26.0, *)
struct LocationInformationManager {

	static let australiaCountryCode = "AU"

	/// `placemark` is deprecated in iOS 26, but its replacements don't expose the state.
	func parseLocation(_ location: CLLocation?) async -> StateLocation {
		guard let location else { return .noState }

		let request = MKReverseGeocodingRequest(location: location)
		let placemark = try? await request?.mapItems.first?.placemark
		return state(from: placemark?.administrativeArea, countryCode: placemark?.isoCountryCode)
	}

	/// The ACT has no produce data of its own, so it uses New South Wales'. Matches on the ISO
	/// country code because the country name is localised to the device's language.
	func state(from administrativeArea: String?, countryCode: String?) -> StateLocation {
		let area = administrativeArea?.lowercased() ?? ""

		if area == StateLocation.act.rawValue {
			return .newSouthWales
		}
		guard countryCode == Self.australiaCountryCode else {
			return .noState
		}
		return StateLocation(rawValue: area) ?? .noState
	}
}
