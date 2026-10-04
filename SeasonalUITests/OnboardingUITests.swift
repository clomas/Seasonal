//
//  OnboardingUITests.swift
//  SeasonalUITests
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import XCTest

@available(iOS 26, *)
final class OnboardingUITests: SeasonalUITestCase {

    private let tipTitle = "Swipe to explore"
    private let peekTimeout: TimeInterval = 15

    func testSwipeTipShowsOnceOnFirstUse() throws {
        try launch(extraArguments: [LaunchArgument.resetOnboarding])
        openTab(TabName.months)

        let tip = app.staticTexts[tipTitle]
        XCTAssertTrue(tip.waitForExistence(timeout: elementTimeout))
        XCTAssertTrue(tip.waitForNonExistence(timeout: peekTimeout), "The tip should fade once the peek finishes")

        app.terminate()
        try launch()
        openTab(TabName.months)

        XCTAssertFalse(app.staticTexts[tipTitle].waitForExistence(timeout: elementTimeout))
    }

    func testSwipeTipDoesNotShowOnFavourites() throws {
        try launch(extraArguments: [LaunchArgument.resetOnboarding])
        openTab(TabName.favourites)

        XCTAssertFalse(app.staticTexts[tipTitle].waitForExistence(timeout: elementTimeout))
    }
}
