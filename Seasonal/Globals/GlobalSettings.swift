//
//  GlobalSettings.swift
//  Seasonal
//
//  Created by Clint Thomas on 29/4/2023.
//  Copyright © 2023 Clint Thomas. All rights reserved.
//

import Foundation

@MainActor
enum GlobalSettings {
	@UserDefault("state", defaultValue: Location(state: "")) static var location: Location
	@UserDefault("hasBeenLaunchedBeforeFlag", defaultValue: App(launchedBefore: false)) static var hasBeenLaunchedBeforeFlag: App
	@UserDefault("selectedTab", defaultValue: .favourites) static var selectedTab: StoredSelectedTab
	@UserDefault("swipeTipShown", defaultValue: TipShown(swipe: false)) static var swipeTipShown: TipShown
	@UserDefault("selectedTheme", defaultValue: .fresh) static var theme: Theme
	@UserDefault("selectedAppearance", defaultValue: .automatic) static var appearance: Appearance
}
