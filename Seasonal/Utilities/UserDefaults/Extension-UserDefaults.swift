//
//  Extension-UserDefaults.swift
//  Seasonal
//
//  Created by Clint Thomas on 30/5/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import Foundation

extension UserDefaults {

	static func isFirstLaunch() -> Bool {
		let isFirstLaunch: Bool = !GlobalSettings.hasBeenLaunchedBeforeFlag.launchedBefore

		if isFirstLaunch {
			GlobalSettings.hasBeenLaunchedBeforeFlag = App(launchedBefore: true)
			UserDefaults.standard.synchronize()
		}
		return isFirstLaunch
	}
}
