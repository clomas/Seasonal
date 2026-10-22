//
//  MainScreenStateTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Testing
@testable import Seasonal

@MainActor
struct MainScreenStateTests {

    private let state = MainScreenState()

    @Test func searchMirrorsTheTabItWasOpenedFrom() {
        state.selectedTab = .seasons

        state.selectedTab = .search

        #expect(state.searchOrigin == .seasons)
        #expect(state.browsingTab == .seasons)
    }

    @Test func browsingTabIsTheSelectedTabOutsideSearch() {
        state.selectedTab = .favourites

        #expect(state.browsingTab == .favourites)
    }

    @Test func leavingSearchClearsTheQuery() {
        state.selectedTab = .search
        state.searchQuery = "apple"

        state.selectedTab = .favourites

        #expect(state.searchQuery.isEmpty)
    }

    @Test func querySurvivesWhileSearching() {
        state.selectedTab = .search
        state.searchQuery = "apple"

        state.selectedTab = .search

        #expect(state.searchQuery == "apple")
    }
}
