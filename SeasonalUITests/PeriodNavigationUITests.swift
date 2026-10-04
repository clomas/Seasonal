//
//  PeriodNavigationUITests.swift
//  SeasonalUITests
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import XCTest

@available(iOS 26, *)
final class PeriodNavigationUITests: SeasonalUITestCase {

    func testTitleMenuJumpsToAMonth() throws {
        try launch()
        openTab(TabName.months)
        let target = currentMonthName == "March" ? "April" : "March"

        let navigationBar = app.navigationBars[currentMonthName]
        XCTAssertTrue(navigationBar.waitForExistence(timeout: elementTimeout))
        navigationBar.buttons.matching(NSPredicate(format: "label == %@", currentMonthName)).firstMatch.tap()
        app.buttons[target].tap()

        XCTAssertTrue(app.navigationBars[target].waitForExistence(timeout: elementTimeout))
    }

    func testSwipingMovesToTheNextMonth() throws {
        try launch()
        openTab(TabName.months)
        let nextMonth = Calendar.current.monthSymbols[Calendar.current.component(.month, from: .now) % 12]

        app.scrollViews.firstMatch.swipeLeft()

        XCTAssertTrue(app.navigationBars[nextMonth].waitForExistence(timeout: elementTimeout))
    }
}
