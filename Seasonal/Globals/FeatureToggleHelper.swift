	//
	//  FeatureToggleHelper.swift
	//  Seasonal
	//
	//  Created by Clint Thomas on 24/8/2025.
	//  Copyright © 2025 Clint Thomas. All rights reserved.
	//

import Foundation
import Combine

enum Feature: String, CaseIterable {
	case useScrollView
	case useToolbarButtons
	case useSwiftUI

	var defaultValue: Bool {
		switch self {
		case .useToolbarButtons: false // False due to animation bug
		case .useSwiftUI:
			if #available(iOS 26, *) {
				true
			} else {
				false
			}
		default: true
		}
	}
}

@MainActor
final class FeatureToggleHelper: ObservableObject {
	@Published private(set) var toggles: [Feature: Bool] = [:]

	init() {
		for feature in Feature.allCases {
			let stored = UserDefaults.standard.object(forKey: feature.rawValue) as? Bool
			toggles[feature] = stored ?? feature.defaultValue
		}
	}

	func isEnabled(_ feature: Feature) -> Bool {
		toggles[feature] ?? false
	}

	func set(_ feature: Feature, enabled: Bool) {
		toggles[feature] = enabled
		UserDefaults.standard.set(enabled, forKey: feature.rawValue)
	}
}
