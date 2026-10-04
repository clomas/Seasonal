//
//  ProduceDiskCacheTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import XCTest
@testable import Seasonal

final class ProduceDiskCacheTests: XCTestCase {

    private let cache = ProduceDiskCache()

    override func setUp() {
        cache.clear()
    }

    override func tearDown() {
        cache.clear()
    }

    func testRoundTripsForTheSameLocation() {
        cache.save([.fixture(id: 1, name: "Apple", months: [.may])], for: .victoria)

        let loaded = cache.load(for: .victoria)

        XCTAssertEqual(loaded?.map(\.id), [1])
        XCTAssertEqual(loaded?.first?.months, [.may])
    }

    func testDifferentLocationMisses() {
        cache.save([.fixture(id: 1, name: "Apple")], for: .victoria)

        XCTAssertNil(cache.load(for: .queensland))
    }

    func testClearRemovesEverything() {
        cache.save([.fixture(id: 1, name: "Apple")], for: .victoria)

        cache.clear()

        XCTAssertNil(cache.load(for: .victoria))
    }
}
