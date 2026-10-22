//
//  FavouriteUITests.swift
//  SeasonalUITests
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import XCTest

@available(iOS 26, *)
final class FavouriteUITests: SeasonalUITestCase {

    private let applesID = 0

    func testUnlikingRemovesItFromFavourites() throws {
        try launch()
        openTab(TabName.favourites)
        XCTAssertTrue(row(named: "Apples").waitForExistence(timeout: elementTimeout))

        app.buttons["produceFavouriteButton_\(applesID)"].tap()

        XCTAssertTrue(row(named: "Apples").waitForNonExistence(timeout: elementTimeout))
    }
}
