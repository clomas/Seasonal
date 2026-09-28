//
//  ProduceStoreTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import XCTest
@testable import Seasonal

@available(iOS 26, *)
@MainActor
final class ProduceStoreTests: XCTestCase {

    func testFavouritesDerivedFromAllProduce() {
        let store = ProduceStore()

        let a = Produce.fixture(id: 1, name: "A", liked: true)
        let b = Produce.fixture(id: 2, name: "B", liked: false)

        store.loadMockData([a, b])

        let favourites = store.favourites
        XCTAssertEqual(favourites.count, 1)
        XCTAssertEqual(favourites.first?.id, 1)
    }

    func testByPeriodReturnsOnlyThatPeriod() {
        let store = ProduceStore()
        let april = Produce.fixture(id: 1, name: "Apple", months: [.april])
        let may = Produce.fixture(id: 2, name: "Mango", months: [.may])

        store.loadMockData([april, may])

        XCTAssertEqual(store.byPeriod(Months.april).map(\.id), [1])
    }

    func testToggleLikedUpdatesProduceAndFavourites() {
        let store = ProduceStore()
        let item = Produce.fixture(id: 1, name: "A", liked: false)
        store.loadMockData([item])

        store.toggleLiked(for: 1)

        XCTAssertEqual(store.favourites.count, 1)
        XCTAssertTrue(store.allProduce.first(where: { $0.id == 1 })?.liked == true)
    }

    func testToggleLikedInvalidatesCachedDerivedLists() {
        let store = ProduceStore()
        let item = Produce.fixture(id: 1, name: "Apple", months: [.april], liked: false)
        store.loadMockData([item])

        XCTAssertEqual(store.byPeriod(Months.april).first?.liked, false)
        XCTAssertEqual(store.favourites.count, 0)

        store.toggleLiked(for: 1)

        XCTAssertEqual(store.byPeriod(Months.april).first?.liked, true)
        XCTAssertEqual(store.favourites.count, 1)
    }
}
