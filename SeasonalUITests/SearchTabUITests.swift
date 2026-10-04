//
//  SearchTabUITests.swift
//  SeasonalUITests
//
//  Created by Clint Thomas on 26/7/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import XCTest

@available(iOS 26, *)
final class SearchTabUITests: SeasonalUITestCase {

    /// Never taps the field: typed text only lands if selecting the tab focused it.
    func testSelectingSearchTabFocusesFieldInOneTap() throws {
        try launch()
        openTab(TabName.favourites)
        openTab(TabName.search)

        app.typeText("carrot")

        XCTAssertTrue(row(named: "Carrots").waitForExistence(timeout: elementTimeout),
                      "Typing straight after selecting the search tab produced no results, so the field didn't take focus")
    }

    func testSearchKeepsTheMonthBeingBrowsed() throws {
        try launch()
        openTab(TabName.months)
        openTab(TabName.search)

        app.typeText("a")

        XCTAssertTrue(app.navigationBars[currentMonthName].waitForExistence(timeout: elementTimeout),
                      "Searching from the months tab should keep the current month on screen")
    }

    func testSearchNarrowsThenCancelRestoresTheList() throws {
        try launch()
        openTab(TabName.favourites)
        openTab(TabName.search)

        app.typeText("carr")

        XCTAssertTrue(row(named: "Carrots").waitForExistence(timeout: elementTimeout))
        XCTAssertFalse(row(named: "Apples").exists)

        app.buttons["Close"].tap()

        XCTAssertTrue(row(named: "Apples").waitForExistence(timeout: elementTimeout))
    }
}
