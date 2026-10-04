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
        #expect(MainTabScreen.Tabs.search.title == Strings.Tab.search)
        #expect(MainTabScreen.Tabs.months(.april).title == Strings.Month.april)
        #expect(MainTabScreen.Tabs.seasons(.summer).title == Strings.Season.summer)
    }

    @Test func emptyMessages() {
        #expect(MainTabScreen.Tabs.favourites.emptyProduceListViewMessage == Strings.EmptyState.favourites)
        #expect(MainTabScreen.Tabs.months(.april).emptyProduceListViewMessage == Strings.EmptyState.period)
    }

    @Test(arguments: Months.allCases)
    func monthTabHasATitle(_ month: Months) {
        #expect(MainTabScreen.Tabs.months(month).title.isEmpty == false)
    }

    @Test(arguments: Seasons.allCases)
    func seasonTabHasATitle(_ season: Seasons) {
        #expect(MainTabScreen.Tabs.seasons(season).title.isEmpty == false)
    }
}
