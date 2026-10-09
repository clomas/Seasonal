//
//  PendingUnlikesTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 4/10/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Testing
@testable import Seasonal

struct PendingUnlikesTests {

    /// Far outside the real produce IDs, so parallel tests can't collide with app data.
    private let id = 900_001

    @Test func unlikeStaysPendingUntilRemoved() {
        defer { PendingUnlikes.remove(id) }

        PendingUnlikes.insert(id)
        #expect(PendingUnlikes.ids.contains(id))

        PendingUnlikes.remove(id)
        #expect(PendingUnlikes.ids.contains(id) == false)
    }
}
