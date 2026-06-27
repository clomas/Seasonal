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
    case hideTabBarLabels
    
    var defaultValue: Bool {
        switch self {
        case .useToolbarButtons: false // False due to animation bug
        case .useSwiftUI:
            if #available(iOS 26, *) {
                true
            } else {
                false
            }
            // On so the cleaner icon-only bar is visible now. In production this starts off and is
            // flipped on automatically once the app has been launched `tabBarLabelHideLaunchCount` times.
        case .hideTabBarLabels: false
        default: true
        }
    }
    
    var overrideDebugValue: Bool? {
        #if DEBUG
        switch self {
        case .hideTabBarLabels:
            false
        default:
            nil
        }
        #else
        nil
        #endif
    }
}

@MainActor
final class FeatureToggleHelper: ObservableObject {
	@Published private(set) var toggles: [Feature: Bool] = [:]

	init() {
		for feature in Feature.allCases {
			let stored = UserDefaults.standard.object(forKey: feature.rawValue) as? Bool
            toggles[feature] = feature.overrideDebugValue ?? stored ?? feature.defaultValue
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
