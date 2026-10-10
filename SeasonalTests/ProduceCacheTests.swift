//
//  ProduceCacheTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Testing
@testable import Seasonal

@MainActor
struct ProduceCacheTests {

    private let cache = ProduceCache()

    @Test func favouritesReturnsOnlyLiked() {
        let liked = Produce.fixture(id: 1, name: "A", liked: true)
        let notLiked = Produce.fixture(id: 2, name: "B", liked: false)

        #expect(cache.favourites(from: [liked, notLiked]).map(\.id) == [1])
    }

    @Test func byPeriodFiltersForMonths() {
        let april = Produce.fixture(id: 1, name: "Apr", months: [.april])
        let may = Produce.fixture(id: 2, name: "May", months: [.may])

        #expect(cache.byPeriod(Months.april, from: [april, may]).map(\.id) == [1])
    }

    @Test func byPeriodFiltersForSeasons() {
        let summer = Produce.fixture(id: 1, name: "S", seasons: [.summer])
        let winter = Produce.fixture(id: 2, name: "W", seasons: [.winter])

        #expect(cache.byPeriod(Seasons.summer, from: [summer, winter]).map(\.id) == [1])
    }

    @Test func derivedListsAreMemoisedUntilInvalidated() {
        let liked = Produce.fixture(id: 1, name: "A", liked: true)

        #expect(cache.favourites(from: [liked]).count == 1)
        #expect(cache.favourites(from: []).count == 1)
    }

    @Test func invalidateForcesRecomputeAcrossAllKeys() {
        let liked = Produce.fixture(id: 1, name: "Apple", months: [.april], liked: true)
        #expect(cache.favourites(from: [liked]).count == 1)
        #expect(cache.byPeriod(Months.april, from: [liked]).count == 1)

        cache.invalidate()

        #expect(cache.favourites(from: []).isEmpty)
        #expect(cache.byPeriod(Months.april, from: []).isEmpty)
    }
}
