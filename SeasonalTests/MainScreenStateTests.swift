//
//  MainScreenStateTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import XCTest
@testable import Seasonal

@available(iOS 26, *)
@MainActor
final class MainScreenStateTests: XCTestCase {

    func testSearchMirrorsTheTabItWasOpenedFrom() {
        let state = MainScreenState()
        state.selectedTab = .seasons(.winter)

        state.selectedTab = .search

        XCTAssertEqual(state.searchOrigin, .seasons(.winter))
        XCTAssertEqual(state.browsingTab, .seasons(.winter))
    }

    func testBrowsingTabIsTheSelectedTabOutsideSearch() {
        let state = MainScreenState()

        state.selectedTab = .favourites

        XCTAssertEqual(state.browsingTab, .favourites)
    }

    func testLeavingSearchClearsTheQuery() {
        let state = MainScreenState()
        state.selectedTab = .search
        state.searchQuery = "apple"

        state.selectedTab = .favourites

        XCTAssertEqual(state.searchQuery, "")
    }

    func testQuerySurvivesWhileSearching() {
        let state = MainScreenState()
        state.selectedTab = .search
        state.searchQuery = "apple"

        state.selectedTab = .search

        XCTAssertEqual(state.searchQuery, "apple")
    }
}
