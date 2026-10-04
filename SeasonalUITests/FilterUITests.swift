//
//  FilterUITests.swift
//  SeasonalUITests
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import XCTest

@available(iOS 26, *)
final class FilterUITests: SeasonalUITestCase {

    func testCategoryFilterNarrowsTheList() throws {
        try launch()
        openTab(TabName.favourites)
        XCTAssertTrue(row(named: "Apples").waitForExistence(timeout: elementTimeout))

        selectCategory("Vegetables")

        XCTAssertTrue(row(named: "Carrots").waitForExistence(timeout: elementTimeout))
        XCTAssertFalse(row(named: "Apples").exists)

        selectCategory("All")

        XCTAssertTrue(row(named: "Apples").waitForExistence(timeout: elementTimeout))
    }

    func testFilterAppliesAcrossTabs() throws {
        try launch()
        openTab(TabName.favourites)
        selectCategory("Herbs")

        openTab(TabName.seasons)

        XCTAssertFalse(row(named: "Apples").exists)
    }

    private func selectCategory(_ name: String) {
        app.buttons["filterByCategoryButton"].tap()
        app.buttons[name].tap()
    }
}
