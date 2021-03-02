//
//  _AppStatus.swift
//  Seasonal
//
//  Created by Clint Thomas on 1/3/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import Foundation

class _AppStatus {

	var viewDisplayed: ViewDisplayed {
		get {
			return UserDefaults.standard[#function] ?? .months
		}
		set {
			UserDefaults.standard[#function] = newValue
		}
	}
}


extension UserDefaults {
	// check for is first launch - only true on first invocation after app install, false on all further invocations
	// Note: Store this value in AppDelegate if you have multiple places where you are checking for this flag
	static func isFirstLaunch() -> Bool {
		let hasBeenLaunchedBeforeFlag = "hasBeenLaunchedBeforeFlag"
		let isFirstLaunch = !UserDefaults.standard.bool(forKey: hasBeenLaunchedBeforeFlag)
		if (isFirstLaunch) {
			UserDefaults.standard.set(true, forKey: hasBeenLaunchedBeforeFlag)
			UserDefaults.standard.synchronize()
		}
		return isFirstLaunch
	}

	subscript<T: RawRepresentable>(key: String) -> T? {
		get {
			if let rawValue = value(forKey: key) as? T.RawValue {
				return T(rawValue: rawValue)
			}
			return nil
		}
		set {
			set(newValue?.rawValue, forKey: key)
		}
	}
}
