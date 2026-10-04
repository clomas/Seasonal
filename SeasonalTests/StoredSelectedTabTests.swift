//
//  StoredSelectedTabTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Testing
@testable import Seasonal

@MainActor
@Suite(.restoresSelectedTab)
struct StoredSelectedTabTests {

    @Test func browsingTabsRoundTrip() {
        StoredSelectedTab.storeTab(.seasons(.winter))
        #expect(StoredSelectedTab.tab == .seasons(Seasons.currentPeriod))

        StoredSelectedTab.storeTab(.months(.march))
        #expect(StoredSelectedTab.tab == .months(Months.currentPeriod))

        StoredSelectedTab.storeTab(.favourites)
        #expect(StoredSelectedTab.tab == .favourites)
    }

    @Test func searchIsNotStored() {
        StoredSelectedTab.storeTab(.favourites)

        StoredSelectedTab.storeTab(.search)

        #expect(StoredSelectedTab.tab == .favourites)
    }
}
