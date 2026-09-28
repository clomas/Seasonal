//
//  MainScreenState.swift
//  Seasonal
//
//  Created by Clint Thomas on 26/7/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Observation
import SwiftUI

@MainActor
@Observable
@available(iOS 26, *)
final class MainScreenState {

    var selectedTab: MainTabScreen.Tabs = StoredSelectedTab.tab {
        didSet { selectedTabChanged() }
    }
    var selectedCategory: ProduceCategory = .all
    var searchQuery = ""

    /// The tab the search tab mirrors while searching.
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
