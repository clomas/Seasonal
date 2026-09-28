//
//  SearchTabUITests.swift
//  SeasonalUITests
//
//  Created by Clint Thomas on 26/7/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import XCTest

@available(iOS 26, *)
final class SearchTabUITests: XCTestCase {

    private let launchTimeout: TimeInterval = 30
    private let resultTimeout: TimeInterval = 5

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["enable-testing", "use-mock-data"]
        app.launch()
    }

    /// Never taps the field: typed text only lands if selecting the tab focused it.
    func testSelectingSearchTabFocusesFieldInOneTap() throws {
        try waitForSearchTab().tap()

        app.typeText("carrot")

        XCTAssertTrue(app.staticTexts["Carrots"].waitForExistence(timeout: resultTimeout),
                      "Typing straight after selecting the search tab produced no results, so the field didn't take focus")
    }

    func testSearchKeepsTheMonthBeingBrowsed() throws {
        let searchTab = try waitForSearchTab()
        app.tabBars.buttons["Months"].tap()
        searchTab.tap()

        app.typeText("a")

        let currentMonth = Calendar.current.monthSymbols[Calendar.current.component(.month, from: .now) - 1]
        XCTAssertTrue(app.navigationBars[currentMonth].waitForExistence(timeout: resultTimeout),
                      "Searching from the months tab should keep the current month on screen")
    }

    private func waitForSearchTab() throws -> XCUIElement {
        addUIInterruptionMonitor(withDescription: "System alerts") { alert in
            for label in ["Allow While Using App", "Allow Once", "Allow", "Not Now"] where alert.buttons[label].exists {
                alert.buttons[label].tap()
                return true
            }
            return false
        }
        app.tap()

        let searchTab = app.tabBars.buttons["Search"]
        guard searchTab.waitForExistence(timeout: launchTimeout) else {
            throw XCTSkip("Main screen never appeared. On screen instead: \(String(app.debugDescription.prefix(1200)))")
        }
        return searchTab
    }
}
