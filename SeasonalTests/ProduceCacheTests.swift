//
//  ProduceCacheTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import XCTest
@testable import Seasonal

@available(iOS 26, *)
@MainActor
final class ProduceCacheTests: XCTestCase {

    func testAllProduceSortedAlphabetically() {
        let cache = ProduceCache()
        let banana = Produce.fixture(id: 1, name: "Banana")
        let apple = Produce.fixture(id: 2, name: "Apple")

        let result = cache.allProduce(from: [banana, apple])
        XCTAssertEqual(result.map { $0.name }, ["Apple", "Banana"])    }

    func testFavouritesReturnsOnlyLiked() {
        let cache = ProduceCache()
        let liked = Produce.fixture(id: 1, name: "A", liked: true)
        let notLiked = Produce.fixture(id: 2, name: "B", liked: false)

        let result = cache.favourites(from: [liked, notLiked])
        XCTAssertEqual(result.count, 1)
        XCTAssertTrue(result.allSatisfy { $0.liked == true })
    }

    func testByPeriodFiltersForMonths() {
        let cache = ProduceCache()
        let aprilProd = Produce.fixture(id: 1, name: "Apr", months: [.april])
        let mayProd = Produce.fixture(id: 2, name: "May", months: [.may])

        let result = cache.byPeriod(Months.april, from: [aprilProd, mayProd])
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, 1)
    }

    func testByPeriodFiltersForSeasons() {
        let cache = ProduceCache()
        let summerProd = Produce.fixture(id: 1, name: "S", seasons: [.summer])
        let winterProd = Produce.fixture(id: 2, name: "W", seasons: [.winter])

        let result = cache.byPeriod(Seasons.summer, from: [summerProd, winterProd])
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, 1)
    }

    func testDerivedListsAreMemoisedUntilInvalidated() {
        let cache = ProduceCache()
        let liked = Produce.fixture(id: 1, name: "A", liked: true)

        XCTAssertEqual(cache.favourites(from: [liked]).count, 1)

        // Different input still returns the cached value until the cache is invalidated.
        XCTAssertEqual(cache.favourites(from: []).count, 1)
    }

    func testInvalidateForcesRecomputeAcrossAllKeys() {
        let cache = ProduceCache()
        let liked = Produce.fixture(id: 1, name: "Apple", months: [.april], liked: true)

        XCTAssertEqual(cache.favourites(from: [liked]).count, 1)
        XCTAssertEqual(cache.byPeriod(Months.april, from: [liked]).count, 1)

        cache.invalidate()

        XCTAssertEqual(cache.favourites(from: []).count, 0)
        XCTAssertEqual(cache.byPeriod(Months.april, from: []).count, 0)
    }
}
