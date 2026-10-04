//
//  PeriodTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import XCTest
@testable import Seasonal

final class PeriodTests: XCTestCase {

    func testMonthContainingDate() throws {
        let calendar = Calendar(identifier: .gregorian)
        let date = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 3, day: 15)))

        XCTAssertEqual(Months(containing: date, calendar: calendar), .march)
    }

    func testMonthIndexIsZeroBased() {
        XCTAssertEqual(Months.january.index, 0)
        XCTAssertEqual(Months.december.index, 11)
    }

    func testMonthFirstLetter() {
        XCTAssertEqual(Months.january.firstLetter, "J")
        XCTAssertEqual(Months.august.firstLetter, "A")
    }

    func testSouthernHemisphereSeasons() {
        let expected: [Months: Seasons] = [
            .december: .summer, .january: .summer, .february: .summer,
            .march: .autumn, .april: .autumn, .may: .autumn,
            .june: .winter, .july: .winter, .august: .winter,
            .september: .spring, .october: .spring, .november: .spring
        ]
        for (month, season) in expected {
            XCTAssertEqual(Seasons(containing: month), season, "\(month)")
        }
    }

    func testPeriodsContainProduceByTheirOwnField() {
        let produce = Produce.fixture(id: 1, name: "Apple", months: [.may], seasons: [.winter])

        XCTAssertTrue(Months.may.contains(produce))
        XCTAssertFalse(Months.june.contains(produce))
        XCTAssertTrue(Seasons.winter.contains(produce))
        XCTAssertFalse(Seasons.summer.contains(produce))
    }

    func testProduceWithoutPeriodsIsNeverInSeason() {
        let produce = Produce.fixture(id: 1, name: "Apple")

        XCTAssertFalse(Months.may.contains(produce))
        XCTAssertFalse(Seasons.winter.contains(produce))
    }

    func testCacheKeysAreDistinctPerPeriod() {
        XCTAssertNotEqual(Months.may.cacheKey, Months.june.cacheKey)
        XCTAssertNotEqual(Seasons.winter.cacheKey, Seasons.summer.cacheKey)
    }
}
