//
//  MainScreenState.swift
//  Seasonal
//
//  Created by Clint Thomas on 26/7/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Observation
import SwiftUI

/// The state shared across the main screen: which tab is showing, what's in the search field,
/// and the category filter.
///
/// Every one of these is written by the tab bar or the toolbar and read by the produce
/// lists two levels down, so they travel through `.environment(_:)` rather than being threaded
/// as a dozen separate bindings and closures through `PeriodPagerView`, which cares about none
/// of them itself. State only one view needs — the onboarding tip, the info sheet, each pager's
/// scroll position — deliberately stays local to that view.
///
/// Being `@Observable` rather than a set of bindings also narrows invalidation: a view only
/// re-renders for the properties it actually reads.
@MainActor
@Observable
@available(iOS 26, *)
final class MainScreenState {

    var selectedTab: MainTabScreen.Tabs = StoredSelectedTab.tab {
        didSet { selectedTabChanged() }
    }
    var selectedCategory: ProduceCategory = .all

    /// Bound to the system search field the `Tab(role: .search)` puts in the tab bar. It only
    /// filters the search tab's copy of `searchOrigin`, and is cleared on leaving search so the
    /// next search opens on the full list again.
    var searchQuery: String = ""

    /// The tab search was opened from. The search tab shows this same screen — title, pager
    /// and all — filtered by `searchQuery`, so searching never loses the month or season.
    private(set) var searchOrigin: MainTabScreen.Tabs = StoredSelectedTab.tab

    /// The screen actually on show: the origin while searching, otherwise the selected tab.
    var browsingTab: MainTabScreen.Tabs {
        selectedTab == .search ? searchOrigin : selectedTab
    }

    private func selectedTabChanged() {
        guard selectedTab != .search else { return }
        searchOrigin = selectedTab
        searchQuery = ""
    }
}
