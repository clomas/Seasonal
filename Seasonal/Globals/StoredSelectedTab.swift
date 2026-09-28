//
//  StoredSelectedTab.swift
//  Seasonal
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

@MainActor
enum StoredSelectedTab: Codable {
	case favourites, months, seasons

	@available(iOS 26, *)
	static var tab: MainTabScreen.Tabs {
		switch GlobalSettings.selectedTab {
		case .favourites: .favourites
		case .months: .months(Months.currentPeriod)
		case .seasons: .seasons(Seasons.currentPeriod)
		}
	}

	/// Search isn't stored: relaunching into an empty search field isn't where anyone left off.
	@available(iOS 26, *)
	static func storeTab(_ tab: MainTabScreen.Tabs) {
		switch tab {
		case .favourites: GlobalSettings.selectedTab = .favourites
		case .months: GlobalSettings.selectedTab = .months
		case .seasons: GlobalSettings.selectedTab = .seasons
		case .search: break
		}
	}
}
