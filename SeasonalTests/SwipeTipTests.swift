//
//  SwipeTipTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 10/10/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Testing
@testable import Seasonal

@MainActor
struct SwipeTipTests {

    @Test func dueOnFreshInstallAndAfterEachUpdate() {
        let original = GlobalSettings.swipeTipShownVersion
        defer { GlobalSettings.swipeTipShownVersion = original }

        GlobalSettings.swipeTipShownVersion = ""
        #expect(GlobalSettings.isSwipeTipDue)

        GlobalSettings.markSwipeTipShown()
        #expect(GlobalSettings.isSwipeTipDue == false)

        GlobalSettings.swipeTipShownVersion = "0.0.1"
        #expect(GlobalSettings.isSwipeTipDue)
    }
}
