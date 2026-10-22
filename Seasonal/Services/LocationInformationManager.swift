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

	func parseLocation(_ location: CLLocation?) async -> StateLocation {
		guard let location else { return .noState }

		let request = MKReverseGeocodingRequest(location: location)
		let address = try? await request?.mapItems.first?.addressRepresentations
		return state(
			from: administrativeArea(fromCityWithContext: address?.cityWithContext(.short)),
			countryCode: address?.region?.identifier
		)
	}

	/// `MKAddressRepresentations` has no structured state, but `cityWithContext` ends with the
	/// state's abbreviation (e.g. "Sydney NSW"), which isn't localised like the city name is.
	func administrativeArea(fromCityWithContext cityWithContext: String?) -> String? {
		cityWithContext?.split(separator: " ").last.map(String.init)
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
