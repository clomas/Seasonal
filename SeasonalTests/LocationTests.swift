//
//  LocationTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import XCTest
@testable import Seasonal

final class LocationTests: XCTestCase {

    func testSelectableStatesExcludeNoStateAndACT() {
        let selectable = StateLocation.selectable

        XCTAssertFalse(selectable.contains(.noState))
        XCTAssertFalse(selectable.contains(.act))
        XCTAssertEqual(selectable.count, StateLocation.allCases.count - 2)
    }

    func testSelectableStatesHaveRealNames() {
        for state in StateLocation.selectable {
            XCTAssertNotEqual(state.fullName, "Error", "\(state)")
        }
    }

    @available(iOS 26, *)
    func testAustralianStateIsParsedFromAbbreviation() {
        let manager = LocationInformationManager()

        XCTAssertEqual(manager.state(from: "VIC", country: Constants.straya), .victoria)
        XCTAssertEqual(manager.state(from: "wa", country: Constants.straya), .westernAustralia)
    }

    @available(iOS 26, *)
    func testACTUsesNewSouthWales() {
        XCTAssertEqual(LocationInformationManager().state(from: "ACT", country: Constants.straya), .newSouthWales)
    }

    @available(iOS 26, *)
    func testOutsideAustraliaHasNoState() {
        XCTAssertEqual(LocationInformationManager().state(from: "CA", country: "United States"), .noState)
    }

    @available(iOS 26, *)
    func testUnknownOrMissingAreaHasNoState() {
        let manager = LocationInformationManager()

        XCTAssertEqual(manager.state(from: nil, country: Constants.straya), .noState)
        XCTAssertEqual(manager.state(from: "Somewhere", country: Constants.straya), .noState)
    }
}
