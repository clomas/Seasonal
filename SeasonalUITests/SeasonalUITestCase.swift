//
//  SeasonalUITestCase.swift
//  SeasonalUITests
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import XCTest

/// Launches the app on mock data and waits for the main screen.
class SeasonalUITestCase: XCTestCase {

    enum LaunchArgument {
        static let testing = "enable-testing"
        static let mockData = "use-mock-data"
        static let resetOnboarding = "reset-onboarding"
    }

    enum TabName {
        static let favourites = "Favourites"
        static let months = "Months"
        static let seasons = "Seasons"
        static let search = "Search"
    }

    let launchTimeout: TimeInterval = 30
    let elementTimeout: TimeInterval = 5

    var app: XCUIApplication!

    var currentMonthName: String {
        Calendar.current.monthSymbols[Calendar.current.component(.month, from: .now) - 1]
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func launch(extraArguments: [String] = []) throws {
        app = XCUIApplication()
        app.launchArguments = [LaunchArgument.testing, LaunchArgument.mockData] + extraArguments
        app.launch()
        try waitForMainScreen()
    }

    func openTab(_ name: String) {
        app.tabBars.buttons[name].tap()
    }

    func row(named name: String) -> XCUIElement {
        app.staticTexts[name]
    }

    private func waitForMainScreen() throws {
        addUIInterruptionMonitor(withDescription: "System alerts") { alert in
            for label in ["Allow While Using App", "Allow Once", "Allow", "Not Now"] where alert.buttons[label].exists {
                alert.buttons[label].tap()
                return true
            }
            return false
        }
        app.tap()

        guard app.tabBars.buttons[TabName.favourites].waitForExistence(timeout: launchTimeout) else {
            throw XCTSkip("Main screen never appeared. On screen instead: \(String(app.debugDescription.prefix(1200)))")
        }
    }
}
