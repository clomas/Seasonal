//
//  MonthRangeOverlayTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import XCTest
@testable import Seasonal

final class MonthRangeOverlayTests: XCTestCase {

    func testNoMonthsHasNoRanges() {
        XCTAssertEqual(MonthRangeOverlay.ranges(of: []), [])
    }

    func testConsecutiveMonthsFormOneRange() {
        XCTAssertEqual(MonthRangeOverlay.ranges(of: [.march, .april, .may]), [3...5])
    }

    func testGapsSplitRanges() {
        XCTAssertEqual(MonthRangeOverlay.ranges(of: [.january, .march, .april, .june]), [1...1, 3...4, 6...6])
    }

    func testOrderAndDuplicatesDoNotMatter() {
        XCTAssertEqual(MonthRangeOverlay.ranges(of: [.may, .april, .april, .march]), [3...5])
    }

    func testYearEndRangesStaySeparate() {
        XCTAssertEqual(MonthRangeOverlay.ranges(of: [.december, .january]), [1...1, 12...12])
    }

    func testWholeYear() {
        XCTAssertEqual(MonthRangeOverlay.ranges(of: Months.allCases), [1...12])
    }
}
