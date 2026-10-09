//
//  MainScreenState.swift
//  Seasonal
//
//  Created by Clint Thomas on 26/7/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Observation

@MainActor
@Observable
@available(iOS 26, *)
final class MainScreenState {

    var selectedTab: MainTabScreen.Tabs = StoredSelectedTab.tab {
        didSet { selectedTabChanged() }
    }
    var selectedCategory: ProduceCategory = .all
    var searchQuery = ""
    /// The search tab builds a second copy of the screen it was opened from; both copies' pagers
    /// share these so they stay on the same period.
    var currentMonthIndex = Months.currentPeriod.index
    var currentSeasonIndex = Seasons.currentPeriod.index
    /// Set by the title menu's picker; the pager scrolls there and clears it.
    var jumpToMonthIndex: Int?
    var jumpToSeasonIndex: Int?

    private(set) var searchOrigin: MainTabScreen.Tabs = StoredSelectedTab.tab

    var browsingTab: MainTabScreen.Tabs {
        selectedTab == .search ? searchOrigin : selectedTab
    }

    private func selectedTabChanged() {
        guard selectedTab != .search else { return }
        searchOrigin = selectedTab
        searchQuery = ""
    }
}
