//
//  CacheTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import XCTest
@testable import Seasonal

final class CacheTests: XCTestCase {

    func testBuildsOnceThenReturnsCachedValue() {
        let cache = Cache<String, Int>()
        var builds = 0

        let first = cache.value(for: "key") { builds += 1; return 1 }
        let second = cache.value(for: "key") { builds += 1; return 2 }

        XCTAssertEqual(first, 1)
        XCTAssertEqual(second, 1)
        XCTAssertEqual(builds, 1)
    }

    func testPeekNeverInserts() {
        let cache = Cache<String, Int>()

        XCTAssertNil(cache.peek(for: "key"))
        XCTAssertNil(cache.peek(for: "key"))
    }

    func testRemoveAllForcesRebuild() {
        let cache = Cache<String, Int>()
        _ = cache.value(for: "key") { 1 }

        cache.removeAll()

        XCTAssertNil(cache.peek(for: "key"))
        XCTAssertEqual(cache.value(for: "key") { 2 }, 2)
    }
}
