//
//  GlobalSettings.swift
//  Seasonal
//
//  Created by Clint Thomas on 29/4/2023.
//  Copyright © 2023 Clint Thomas. All rights reserved.
//

import Foundation

enum GlobalSettings {
	// Storing location (Australian State) into User Defaults
	@UserDefault("state", defaultValue: Location(state: "")) static var location: Location
	@UserDefault("hasBeenLaunchedBeforeFlag", defaultValue: App(launchedBefore: false)) static var hasBeenLaunchedBeforeFlag: App
}

struct Location: Codable {
	let state: String
}

struct App: Codable {
	let launchedBefore: Bool
}
