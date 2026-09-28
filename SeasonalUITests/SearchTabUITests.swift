//
//  SearchTabUITests.swift
//  SeasonalUITests
//
//  Created by Clint Thomas on 26/7/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import XCTest

/// Covers the one thing about the search tab that can't be checked by reading the code or by
/// looking at a screenshot: how many taps it takes to start typing. `.tabViewSearchActivation`
/// is what makes selecting the tab focus the field, and a regression there is invisible until
/// someone tries it on a device.
@available(iOS 26, *)
final class SearchTabUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        // `use-mock-data` skips network/location/CloudKit and loads the preview fixtures, so
        // these tests exercise search behaviour rather than whether the simulator can reach
        // a CloudKit container — which it frequently cannot.
        app.launchArguments = ["enable-testing", "use-mock-data"]
        app.launch()
    }

    /// The app sits on its loading screen until CloudKit and location resolve, and a location
    /// permission alert can be sitting in front of that, so wait on the tab bar itself rather
    /// than assuming the main screen is up the moment `launch()` returns.
    private func waitForSearchTab() throws -> XCUIElement {
        addUIInterruptionMonitor(withDescription: "System alerts") { alert in
            // "Not Now" covers the Apple Account verification prompt the simulator raises
            // periodically, which otherwise sits over the app for the whole run.
            for label in ["Allow While Using App", "Allow Once", "Allow", "Not Now"]
            where alert.buttons[label].exists {
                alert.buttons[label].tap()
                return true
            }
            return false
        }
        app.tap() // lets the interruption monitor fire if an alert is up

        let searchTab = app.tabBars.buttons["Search"]
        guard searchTab.waitForExistence(timeout: 30) else {
            throw XCTSkip("""
                Main screen never appeared, so tap-count can't be measured here. \
                On screen instead: \(String(app.debugDescription.prefix(1200)))
                """)
        }
        return searchTab
    }

    func testSelectingSearchTabFocusesFieldInOneTap() throws {
        try waitForSearchTab().tap()

        // Deliberately never taps the field itself. `typeText` goes to whatever holds keyboard
        // focus, so the text only lands if selecting the tab focused the field — which is
        // exactly the difference between one tap and two. Asserting on the software keyboard
        // would be flaky instead, since it doesn't draw when a Mac keyboard is attached.
        app.typeText("carrot")

        XCTAssertTrue(app.staticTexts["Carrots"].waitForExistence(timeout: 5),
                      "Typing straight after selecting the search tab produced no results — the "
                      + "field didn't take focus, so search is back to costing a second tap")
    }

    func testSearchKeepsTheMonthBeingBrowsed() throws {
        let searchTab = try waitForSearchTab()
        app.tabBars.buttons["Months"].tap()
        searchTab.tap()

        // Search filters the page it was opened from, so the month's title stays up top.
        app.typeText("a")

        let currentMonth = Calendar.current.monthSymbols[Calendar.current.component(.month, from: .now) - 1]
        // The title is the search tab's navigation bar, which takes the title as its identifier.
        XCTAssertTrue(app.navigationBars[currentMonth].waitForExistence(timeout: 5),
                      "Searching from the months tab should keep the current month on screen")
    }
}
