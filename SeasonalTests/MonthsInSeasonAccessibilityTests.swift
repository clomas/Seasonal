//
//  MonthsInSeasonAccessibilityTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 4/10/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Foundation
import Testing
@testable import Seasonal

@MainActor
struct MonthsInSeasonAccessibilityTests {

    @Test(arguments: [
        (Months.allCases, Strings.Produce.allYear),
        ([.may], Strings.Month.may),
        ([.march, .april, .may], Strings.Produce.monthRange(from: Strings.Month.march, to: Strings.Month.may)),
        ([.may, .march, .april], Strings.Produce.monthRange(from: Strings.Month.march, to: Strings.Month.may)),
        ([.december, .january, .february], Strings.Produce.monthRange(from: Strings.Month.december, to: Strings.Month.february)),
        ([.january, .december], Strings.Produce.monthRange(from: Strings.Month.december, to: Strings.Month.january)),
        (Months.allCases.filter { $0 != .june }, Strings.Produce.monthRange(from: Strings.Month.july, to: Strings.Month.may)),
        (
            [.january, .march, .april],
            [Strings.Month.january, Strings.Produce.monthRange(from: Strings.Month.march, to: Strings.Month.april)]
                .formatted(.list(type: .and))
        ),
        (
            [.december, .january, .june],
            [Strings.Produce.monthRange(from: Strings.Month.december, to: Strings.Month.january), Strings.Month.june]
                .formatted(.list(type: .and))
        )
    ])
    func spokenDescription(of months: [Months], expected: String) {
        #expect(MonthsInSeasonCapsuleView.accessibilityDescription(of: months) == expected)
    }
}
