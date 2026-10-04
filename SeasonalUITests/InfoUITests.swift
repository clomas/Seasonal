//
//  InfoUITests.swift
//  SeasonalUITests
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import XCTest

@available(iOS 26, *)
final class InfoUITests: SeasonalUITestCase {

    func testInfoSheetOpensAndCloses() throws {
        try launch()

        app.buttons["infoButton"].tap()

        let sheet = app.navigationBars["Seasonal"]
        XCTAssertTrue(sheet.waitForExistence(timeout: elementTimeout))
        XCTAssertTrue(app.staticTexts["Produce location"].exists)

        sheet.buttons["Done"].tap()

        XCTAssertTrue(sheet.waitForNonExistence(timeout: elementTimeout))
    }
}
