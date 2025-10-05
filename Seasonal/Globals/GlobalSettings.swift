//
//  GlobalSettings.swift
//  Seasonal
//
//  Created by Clint Thomas on 29/4/2023.
//  Copyright © 2023 Clint Thomas. All rights reserved.
//

import SwiftUI

@MainActor
enum GlobalSettings {
	// Storing location (Australian State) into User Defaults
	@UserDefault("state", defaultValue: Location(state: "")) static var location: Location
	@UserDefault("hasBeenLaunchedBeforeFlag", defaultValue: App(launchedBefore: false)) static var hasBeenLaunchedBeforeFlag: App
	@UserDefault("selectedTab", defaultValue: .favourites) static var selectedTab: StoredSelectedTab
	@UserDefault("swipeTipShown", defaultValue: TipShown(swipe: false)) static var swipeTipShown: TipShown
}

@MainActor
enum StoredSelectedTab: Codable {
	case favourites, months, seasons

	@available(iOS 26, *)
	static func storeTab(_ tab: MainTabScreen.Tabs) {
		switch tab {
		case .favourites:
			GlobalSettings.selectedTab = .favourites

		case .period(let anyPeriod):
			if let _ = anyPeriod.cast(Months.self) {
				GlobalSettings.selectedTab = .months
			} else if let _ = anyPeriod.cast(Seasons.self) {
				GlobalSettings.selectedTab = .seasons
			}

		default:
			break
		}
	}

	@available(iOS 26, *)
	static var tab: MainTabScreen.Tabs {
		switch GlobalSettings.selectedTab {
		case .favourites:
			return .favourites
		case .months:
			return .period(AnyPeriod(Months.currentPeriod))
		case .seasons:
			return .period(AnyPeriod(Seasons.currentPeriod))
		}
	}
}

@MainActor
struct Location: Codable {
	let state: String
}

struct App: Codable {
	let launchedBefore: Bool
}

struct TipShown: Codable {
	let swipe: Bool
}

struct Colour {
	static let welcomeBackground = Color("welcomeBackground")
	static let inSeason = Color("inSeason")
	static let background = Color("tableViewCell")
	static let emptyHeartGradient1 = Color("emptyHeartGradient1")
	static let emptyHeartGradient2 = Color("emptyHeartGradient2")
}

