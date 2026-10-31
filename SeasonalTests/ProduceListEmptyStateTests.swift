//
//  ProduceListEmptyStateTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 31/10/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Testing
@testable import Seasonal

@MainActor
struct ProduceListEmptyStateTests {

    private let summer = Strings.Season.summer
    private let fruit = Strings.Category.fruit.localizedLowercase

    @Test func favouritesWithoutFilter() {
        let state = ProduceListEmptyState(parentTab: .favourites, category: .all, periodTitle: nil, searchText: "")

        #expect(state.message == Strings.EmptyState.favourites)
    }

    @Test func favouritesReferenceTheFilter() {
        let state = ProduceListEmptyState(parentTab: .favourites, category: .fruit, periodTitle: nil, searchText: "")

        #expect(state.message == Strings.EmptyState.favourites(in: fruit))
    }

    @Test func periodWithoutFilter() {
        let state = ProduceListEmptyState(parentTab: .seasons, category: .all, periodTitle: summer, searchText: "")

        #expect(state.message == Strings.EmptyState.period)
    }

    @Test func periodReferencesTheFilterAndPeriod() {
        let state = ProduceListEmptyState(parentTab: .seasons, category: .fruit, periodTitle: summer, searchText: "")

        #expect(state.message == Strings.EmptyState.category(fruit, in: summer))
    }

    @Test func favouritesSearchWithoutFilterUsesSystemDescription() {
        let state = ProduceListEmptyState(parentTab: .favourites, category: .all, periodTitle: nil, searchText: "kiwi")

        #expect(state.searchDescription == nil)
    }

    @Test func favouritesSearchReferencesTheFilter() {
        let state = ProduceListEmptyState(parentTab: .favourites, category: .fruit, periodTitle: nil, searchText: "kiwi")

        #expect(state.searchDescription == Strings.EmptyState.searchFavourites(in: fruit))
    }

    @Test func periodSearchReferencesThePeriod() {
        let state = ProduceListEmptyState(parentTab: .seasons, category: .all, periodTitle: summer, searchText: "kiwi")

        #expect(state.searchDescription == Strings.EmptyState.search(in: summer))
    }

    @Test func periodSearchReferencesTheFilterAndPeriod() {
        let state = ProduceListEmptyState(parentTab: .seasons, category: .fruit, periodTitle: summer, searchText: "kiwi")

        #expect(state.searchDescription == Strings.EmptyState.searchCategory(fruit, in: summer))
    }
}
