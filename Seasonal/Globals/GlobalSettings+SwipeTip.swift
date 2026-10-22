//
//  GlobalSettings+SwipeTip.swift
//  Seasonal
//
//  Created by Clint Thomas on 10/10/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Foundation

/// Once per app version, so the onboarding peek and tip return after an update as well as on a fresh install.
extension GlobalSettings {

	static var isSwipeTipDue: Bool {
		swipeTipShownVersion != currentVersion
	}

	static func markSwipeTipShown() {
		swipeTipShownVersion = currentVersion
	}

	private static var currentVersion: String {
		Bundle.main.shortVersion ?? ""
	}
}
