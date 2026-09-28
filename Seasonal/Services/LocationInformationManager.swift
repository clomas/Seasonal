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

	func parseLocation(_ location: CLLocation?) async -> StateLocation {
		guard let location else { return .noState }

		let request = MKReverseGeocodingRequest(location: location)
		let placemark = try? await request?.mapItems.first?.placemark
		return state(from: placemark?.administrativeArea, country: placemark?.country)
	}

	/// The ACT has no produce data of its own, so it uses New South Wales'.
	private func state(from administrativeArea: String?, country: String?) -> StateLocation {
		let area = administrativeArea?.lowercased() ?? ""

		if area == StateLocation.act.rawValue {
			return .newSouthWales
		}
		guard country == Constants.straya else {
			return .noState
		}
		return StateLocation(rawValue: area) ?? .noState
	}
}
