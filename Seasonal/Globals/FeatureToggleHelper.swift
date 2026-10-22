//
//  FeatureToggleHelper.swift
//  Seasonal
//
//  Created by Clint Thomas on 24/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import Foundation

@MainActor
final class FeatureToggleHelper {

	private var toggles: [Feature: Bool] = [:]

	init() {
		for feature in Feature.allCases {
			let stored = UserDefaults.standard.object(forKey: feature.rawValue) as? Bool
			toggles[feature] = stored ?? feature.defaultValue
		}
	}

	func isEnabled(_ feature: Feature) -> Bool {
		toggles[feature] ?? false
	}
}
