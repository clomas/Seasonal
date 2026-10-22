//
//  TabNavigationUITests.swift
//  SeasonalUITests
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import XCTest

@available(iOS 26, *)
final class TabNavigationUITests: SeasonalUITestCase {

    func testFavouritesShowsOnlyFavourites() throws {
        try launch()
        openTab(TabName.favourites)

        XCTAssertTrue(app.navigationBars[TabName.favourites].waitForExistence(timeout: elementTimeout))
        XCTAssertTrue(row(named: "Apples").exists)
        XCTAssertFalse(row(named: "Pears").exists, "Pears isn't a favourite in the mock data")
    }

    func testMonthsOpensOnTheCurrentMonth() throws {
        try launch()
        openTab(TabName.months)

        XCTAssertTrue(app.navigationBars[currentMonthName].waitForExistence(timeout: elementTimeout))
    }

    func testSeasonsHaveNoMonthStrip() throws {
        try launch()
        openTab(TabName.seasons)

        XCTAssertTrue(app.buttons["filterByCategoryButton"].waitForExistence(timeout: elementTimeout))
        XCTAssertFalse(app.descendants(matching: .any)["monthsInSeason"].exists, "Season rows shouldn't show the month strip")
    }

    func testLastTabIsRestoredOnRelaunch() throws {
        try launch()
        openTab(TabName.seasons)
        app.terminate()

        try launch()

        XCTAssertTrue(app.tabBars.buttons[TabName.seasons].isSelected)
    }
}
