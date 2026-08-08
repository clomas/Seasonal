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
	@UserDefault("state", defaultValue: Location(state: "")) static var location: Location
	@UserDefault("hasBeenLaunchedBeforeFlag", defaultValue: App(launchedBefore: false)) static var hasBeenLaunchedBeforeFlag: App
	@UserDefault("selectedTab", defaultValue: .favourites) static var selectedTab: StoredSelectedTab
	@UserDefault("swipeTipShown", defaultValue: TipShown(swipe: false)) static var swipeTipShown: TipShown
	@UserDefault("produceCacheLastAppVersion", defaultValue: "") static var produceCacheAppVersion: String
	@UserDefault("appLaunchCount", defaultValue: 0) static var appLaunchCount: Int
}

/// Number of launches after which the tab bar drops its text labels for the cleaner icon-only look.
let tabBarLabelHideLaunchCount = 10

@MainActor
enum StoredSelectedTab: Codable {
	case favourites, months, seasons

	@available(iOS 26, *)
	static func storeTab(_ tab: MainTabScreen.Tabs) {
		switch tab {
		case .favourites:
			GlobalSettings.selectedTab = .favourites
		case .months:
			GlobalSettings.selectedTab = .months
		case .seasons:
			GlobalSettings.selectedTab = .seasons
		case .search:
			// Deliberately not persisted: relaunching straight into an empty search field
			// with the keyboard up isn't where anyone left off.
			break
		}
	}

	@available(iOS 26, *)
	static var tab: MainTabScreen.Tabs {
		switch GlobalSettings.selectedTab {
		case .favourites:
			return .favourites
		case .months:
			return .months(Months.currentPeriod)
		case .seasons:
			return .seasons(Seasons.currentPeriod)
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
	static let inSeason = Color("inSeason")
	static let background = Color("tableViewCell")
	static let emptyHeartGradient1 = Color("emptyHeartGradient1")
	static let emptyHeartGradient2 = Color("emptyHeartGradient2")

	// MARK: Semantic aliases (design language)

	/// Primary green accent. Semantic name for `inSeason`.
	static let accent = inSeason
	/// Card / cell surface.
	static let surface = Color("cellColor")
	/// Adaptive foreground for use on top of `accent` (white in light mode,
	/// near-black-green in dark mode). Keeps glyphs/letters legible in both.
	static let onAccent = Color("onAccent")
	/// Translucent accent fill for in-season range capsules.
	static let capsuleFill = inSeason.opacity(0.18)
	/// Accent stroke for in-season range capsules.
	static let capsuleStroke = inSeason.opacity(0.45)
	/// Selection highlight behind active tab-bar / filter controls.
	static let accentHighlight = inSeason.opacity(0.30)
}

