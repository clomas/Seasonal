//
//  Extension-UserDefaults.swift
//  Seasonal
//
//  Created by Clint Thomas on 30/5/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//
// thank you - https://stackoverflow.com/a/36254650/6440209

import Foundation

extension UserDefaults {

	// MARK: Has app been opened before?

	// check for is first launch - only true on first invocation after app install, false on all further invocations
	// Note: Store this value in AppDelegate if you have multiple places where you are checking for this flag
	static func isFirstLaunch() -> Bool {
		let hasBeenLaunchedBeforeFlag = "hasBeenLaunchedBeforeFlag"
		let isFirstLaunch = !UserDefaults.standard.bool(forKey: hasBeenLaunchedBeforeFlag)
		if isFirstLaunch {
			UserDefaults.standard.set(true, forKey: hasBeenLaunchedBeforeFlag)
			UserDefaults.standard.synchronize()
		}
		return isFirstLaunch
	}
}
