//
//  MonthRangeOverlayTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Testing
@testable import Seasonal

struct MonthRangeOverlayTests {

    @Test(arguments: [
        ([Months](), [ClosedRange<Int>]()),
        ([.march, .april, .may], [3...5]),
        ([.january, .march, .april, .june], [1...1, 3...4, 6...6]),
        ([.may, .april, .april, .march], [3...5]),
        ([.december, .january], [1...1, 12...12]),
        (Months.allCases, [1...12])
    ])
    func ranges(of months: [Months], expected: [ClosedRange<Int>]) {
        #expect(MonthRangeOverlay.ranges(of: months) == expected)
    }
}
