//
//  SeasonalUITests.swift
//  SeasonalUITests
//
//  Created by Clint Thomas on 25/5/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import XCTest

class SeasonalUITests: XCTestCase {

	var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
		app = XCUIApplication()
		app.launchArguments = ["enable-testing"]
		app.launch()
		let collectionView = app.collectionViews["menuBar"]
		_ = collectionView.waitForExistence(timeout: 4)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }

	func testMenuBarAnimationAndNumberOfCells() {
		let collectionView = app.collectionViews["menuBar"]
		XCTAssertEqual(collectionView.cells.count, 5)
		collectionView.cells.element(boundBy: 4).tap()

		_ = collectionView.cells.element(boundBy: 5).waitForExistence(timeout: 1)
		XCTAssertEqual(collectionView.cells.count, 5)

		// cancel cell is visible after animation
		let cell = collectionView.cells.element(matching: .cell, identifier: "cancelCell")
		XCTAssertNotNil(cell)

		cell.tap()
		// slide back in and still see 5 cells
		_ = collectionView.cells.element(boundBy: 5).waitForExistence(timeout: 1)
		XCTAssertEqual(collectionView.cells.count, 5)
	}

	func testMonthPickerViewHasAllMonths() {
		// tap menuBar to open Picker View
		let collectionView = app.collectionViews["menuBar"]
		collectionView.cells.element(boundBy: 1).tap()
		// find the presented CollectionView
		let monthPickerCollectionView = app.collectionViews["monthPicker"]
		// Assert 12 months
		XCTAssertEqual(monthPickerCollectionView.cells.count, 12)
		// tap on cell 4 (April)
		monthPickerCollectionView.cells.element(boundBy: 4).tap()
		// Does navigation bar say April?
		let navigationTitleElement = app.navigationBars.matching(identifier: "April").firstMatch
		let navigationBarString = String(describing: navigationTitleElement)
		XCTAssertEqual(navigationBarString, "\"April\" NavigationBar")
	}
}
