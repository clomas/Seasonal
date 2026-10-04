//
//  StoredSelectedTabTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import XCTest
@testable import Seasonal

@available(iOS 26, *)
@MainActor
final class StoredSelectedTabTests: XCTestCase {

    private var originalTab: StoredSelectedTab!

    override func setUp() async throws {
        originalTab = GlobalSettings.selectedTab
    }

    override func tearDown() async throws {
        GlobalSettings.selectedTab = originalTab
    }

    func testBrowsingTabsRoundTrip() {
        StoredSelectedTab.storeTab(.seasons(.winter))
        XCTAssertEqual(StoredSelectedTab.tab, .seasons(Seasons.currentPeriod))

        StoredSelectedTab.storeTab(.months(.march))
        XCTAssertEqual(StoredSelectedTab.tab, .months(Months.currentPeriod))

        StoredSelectedTab.storeTab(.favourites)
        XCTAssertEqual(StoredSelectedTab.tab, .favourites)
    }

    func testSearchIsNotStored() {
        StoredSelectedTab.storeTab(.favourites)

        StoredSelectedTab.storeTab(.search)

        XCTAssertEqual(StoredSelectedTab.tab, .favourites)
    }
}
