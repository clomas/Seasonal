//
//  CacheTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Testing
@testable import Seasonal

struct CacheTests {

    @Test func buildsOnceThenReturnsCachedValue() {
        let cache = Cache<String, Int>()
        var builds = 0

        let first = cache.value(for: "key") { builds += 1; return 1 }
        let second = cache.value(for: "key") { builds += 1; return 2 }

        #expect(first == 1)
        #expect(second == 1)
        #expect(builds == 1)
    }

    @Test func peekNeverInserts() {
        let cache = Cache<String, Int>()
        var builds = 0

        #expect(cache.peek(for: "key") == nil)
        let value = cache.value(for: "key") { builds += 1; return 1 }

        #expect(value == 1)
        #expect(builds == 1)
    }

    @Test func removeAllForcesRebuild() {
        let cache = Cache<String, Int>()
        _ = cache.value(for: "key") { 1 }

        cache.removeAll()

        #expect(cache.peek(for: "key") == nil)
        #expect(cache.value(for: "key") { 2 } == 2)
    }
}
