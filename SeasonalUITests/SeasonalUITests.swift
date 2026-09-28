//
//  SeasonalUITests.swift
//  SeasonalUITests
//
//  Created by Clint Thomas on 25/5/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import XCTest

/// Covers the UIKit interface used below iOS 26.
class SeasonalUITests: XCTestCase {

	private let launchTimeout: TimeInterval = 4
	private let animationTimeout: TimeInterval = 1
	private let menuBarCellCount = 5

	var app: XCUIApplication!

	override func setUpWithError() throws {
		continueAfterFailure = false
		app = XCUIApplication()
		app.launchArguments = ["enable-testing"]
		app.launch()
		_ = app.collectionViews["menuBar"].waitForExistence(timeout: launchTimeout)
	}

	func testLaunchPerformance() throws {
		measure(metrics: [XCTApplicationLaunchMetric()]) {
			XCUIApplication().launch()
		}
	}

	func testMenuBarAnimationAndNumberOfCells() {
		let collectionView = app.collectionViews["menuBar"]
		XCTAssertEqual(collectionView.cells.count, menuBarCellCount)
		collectionView.cells.element(boundBy: 4).tap()

		_ = collectionView.cells.element(boundBy: 5).waitForExistence(timeout: animationTimeout)
		XCTAssertEqual(collectionView.cells.count, menuBarCellCount)

		let cancelCell = collectionView.cells.element(matching: .cell, identifier: "cancelCell")
		XCTAssertNotNil(cancelCell)

		cancelCell.tap()
		_ = collectionView.cells.element(boundBy: 5).waitForExistence(timeout: animationTimeout)
		XCTAssertEqual(collectionView.cells.count, menuBarCellCount)
	}

	func testMonthPickerViewHasAllMonths() {
		app.collectionViews["menuBar"].cells.element(boundBy: 1).tap()

		let monthPicker = app.collectionViews["monthPicker"]
		XCTAssertEqual(monthPicker.cells.count, 12)

		monthPicker.cells.element(boundBy: 4).tap()
		let navigationBar = app.navigationBars.matching(identifier: "April").firstMatch
		XCTAssertEqual(String(describing: navigationBar), "\"April\" NavigationBar")
	}
}
