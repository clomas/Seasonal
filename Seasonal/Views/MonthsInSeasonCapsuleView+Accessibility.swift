//
//  MonthsInSeasonCapsuleView+Accessibility.swift
//  Seasonal
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Foundation

extension MonthsInSeasonCapsuleView {

	/// Spoken form of the capsules, e.g. "December to February and June".
	static func accessibilityDescription(of months: [Months]) -> String {
		var ranges = MonthRangeOverlay.ranges(of: months)
		guard ranges.count > 1 || ranges.first?.count != Months.allCases.count else {
			return Strings.Produce.allYear
		}
		if ranges.count > 1, let first = ranges.first, let last = ranges.last,
		   first.lowerBound == 1, last.upperBound == Months.allCases.count {
			ranges.removeFirst()
			ranges.removeLast()
			ranges.insert(last.lowerBound...(last.upperBound + first.upperBound), at: 0)
		}
		return ranges.map(description(of:)).formatted(.list(type: .and))
	}

	private static func description(of range: ClosedRange<Int>) -> String {
		let start = title(ofMonth: range.lowerBound)
		guard range.count > 1 else { return start }
		return Strings.Produce.monthRange(from: start, to: title(ofMonth: range.upperBound))
	}

	/// Wraps past December so a run crossing the year end resolves to the right month.
	private static func title(ofMonth number: Int) -> String {
		let count = Months.allCases.count
		return Months(rawValue: (number - 1) % count + 1)?.title ?? ""
	}
}
