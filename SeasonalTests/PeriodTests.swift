//
//  PeriodTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Foundation
import Testing
@testable import Seasonal

struct PeriodTests {

    @Test func monthContainingDate() throws {
        let calendar = Calendar(identifier: .gregorian)
        let date = try #require(calendar.date(from: DateComponents(year: 2026, month: 3, day: 15)))

        #expect(Months(containing: date, calendar: calendar) == .march)
    }

    @Test(arguments: zip(Months.allCases, Months.allCases.indices))
    func monthIndexIsZeroBased(_ month: Months, expected: Int) {
        #expect(month.index == expected)
    }

    @Test(arguments: zip(Months.allCases, ["J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D"]))
    func monthFirstLetter(_ month: Months, expected: String) {
        #expect(month.firstLetter == expected)
    }

    @Test(arguments: [
        (Months.december, Seasons.summer), (.january, .summer), (.february, .summer),
        (.march, .autumn), (.april, .autumn), (.may, .autumn),
        (.june, .winter), (.july, .winter), (.august, .winter),
        (.september, .spring), (.october, .spring), (.november, .spring)
    ])
    func southernHemisphereSeason(of month: Months, expected: Seasons) {
        #expect(Seasons(containing: month) == expected)
    }

    @Test func periodsContainProduceByTheirOwnField() {
        let produce = Produce.fixture(id: 1, name: "Apple", months: [.may], seasons: [.winter])

        #expect(Months.may.contains(produce))
        #expect(Months.june.contains(produce) == false)
        #expect(Seasons.winter.contains(produce))
        #expect(Seasons.summer.contains(produce) == false)
    }

    @Test func produceWithoutPeriodsIsNeverInSeason() {
        let produce = Produce.fixture(id: 1, name: "Apple")

        #expect(Months.may.contains(produce) == false)
        #expect(Seasons.winter.contains(produce) == false)
    }

    @Test func cacheKeysAreDistinctPerPeriod() {
        #expect(Set(Months.allCases.map(\.cacheKey)).count == Months.allCases.count)
        #expect(Set(Seasons.allCases.map(\.cacheKey)).count == Seasons.allCases.count)
    }
}
