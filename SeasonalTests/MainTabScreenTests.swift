//
//  MainTabScreenTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Testing
@testable import Seasonal

struct MainTabScreenTests {

    @Test func tabTitles() {
        #expect(MainTabScreen.Tabs.favourites.title == Strings.Tab.favourites)
        #expect(MainTabScreen.Tabs.months.title == Strings.Tab.months)
        #expect(MainTabScreen.Tabs.seasons.title == Strings.Tab.seasons)
        #expect(MainTabScreen.Tabs.search.title == Strings.Tab.search)
    }

    @Test func emptyMessages() {
        #expect(MainTabScreen.Tabs.favourites.emptyProduceListViewMessage == Strings.EmptyState.favourites)
        #expect(MainTabScreen.Tabs.months.emptyProduceListViewMessage == Strings.EmptyState.period)
    }

    @Test(arguments: [(MainTabScreen.Tabs.months, true), (.seasons, true), (.favourites, false), (.search, false)])
    func onlyPeriodTabsHaveAPicker(_ tab: MainTabScreen.Tabs, expected: Bool) {
        #expect(tab.hasPeriodPicker == expected)
    }
}
