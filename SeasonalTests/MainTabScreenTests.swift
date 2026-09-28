//
//  MainTabScreenTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import XCTest
@testable import Seasonal

@available(iOS 26, *)
final class MainTabScreenTests: XCTestCase {

    func testTabTitles() {
        XCTAssertEqual(MainTabScreen.Tabs.favourites.title, Strings.Tab.favourites)
        XCTAssertEqual(MainTabScreen.Tabs.search.title, Strings.Tab.search)
        XCTAssertEqual(MainTabScreen.Tabs.months(.april).title, Strings.Month.april)
        XCTAssertEqual(MainTabScreen.Tabs.seasons(.summer).title, Strings.Season.summer)
    }

    func testEmptyMessages() {
        XCTAssertEqual(MainTabScreen.Tabs.favourites.emptyProduceListViewMessage, Strings.EmptyState.favourites)
        XCTAssertEqual(MainTabScreen.Tabs.months(.april).emptyProduceListViewMessage, Strings.EmptyState.period)
    }

    func testEveryMonthHasATitle() {
        for month in Months.allCases {
            XCTAssertFalse(MainTabScreen.Tabs.months(month).title.isEmpty, "\(month)")
        }
    }

    func testEverySeasonHasATitle() {
        for season in Seasons.allCases {
            XCTAssertFalse(MainTabScreen.Tabs.seasons(season).title.isEmpty, "\(season)")
        }
    }
}
