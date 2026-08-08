//
//  MainScreenState.swift
//  Seasonal
//
//  Created by Clint Thomas on 26/7/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Observation
import SwiftUI

/// The chrome state shared across the main screen: which tab is showing, what's in the search
/// field, the category filter, and whether the top overlay buttons are visible.
///
/// Every one of these is written by the tab bar or the top-right chrome and read by the produce
/// lists two levels down, so they travel through `.environment(_:)` rather than being threaded
/// as a dozen separate bindings and closures through `PeriodPagerView`, which cares about none
/// of them itself. State only one view needs — the onboarding tip, the info sheet, each pager's
/// scroll position — deliberately stays local to that view.
///
/// Being `@Observable` rather than a set of bindings also narrows invalidation: a view only
/// re-renders for the properties it actually reads, so `chromeVisible` flipping on scroll no
/// longer rebuilds the lists that merely pass it along.
@MainActor
@Observable
@available(iOS 26, *)
final class MainScreenState {

    var selectedTab: MainTabScreen.Tabs = StoredSelectedTab.tab
    var selectedCategory: ProduceCategory = .all

    /// Bound to the system search field the `Tab(role: .search)` puts in the tab bar. Search is
    /// its own tab now, so this scopes `SearchScreen` only — the month and season pagers show
    /// their full period lists regardless of what's typed here.
    var searchQuery: String = ""

    /// Drives the top overlay buttons: hidden while scrolling down, shown while scrolling up
    /// or near the top.
    var chromeVisible: Bool = true
}
