//
//  Month.swift
//  Seasonal
//
//  Created by Clint Thomas on 9/4/2023.
//  Copyright © 2023 Clint Thomas. All rights reserved.
//

import Foundation

enum MonthOld: Int, CaseIterable {
	case decemberOverflow
	case january
	case february
	case march
	case april
	case may
	case june
	case july
	case august
	case september
	case october
	case november
	case december
	case januaryOverflow

	var firstLetter: String {
		"\(self)".first?.uppercased() ?? ""
	}
}

enum Month: Int, CaseIterable {
	case january
	case february
	case march
	case april
	case may
	case june
	case july
	case august
	case september
	case october
	case november
	case december

	var firstLetter: String {
		"\(self)".first?.uppercased() ?? ""
	}

	var name: String {
		String(describing: self).capitalized
	}

	static let thisMonth: Month = Month(rawValue: Calendar.current.component(.month, from: Date())) ?? .december

	func next() -> Month {
		let all = Self.allCases
		guard let index = all.firstIndex(of: self) else { return self }
		return all[(index + 1) % all.count]
	}

	func previous() -> Month {
		let all = Self.allCases
		guard let index = all.firstIndex(of: self) else { return self }
		return all[(index - 1 + all.count) % all.count]
	}

	var index: Int {
		Month.allCases.firstIndex(of: self) ?? 0
	}
}

extension Calendar {

	func isDateInThisMonth(_ date: Date) -> Bool {
		isDate(date, equalTo: Date(), toGranularity: .month)
	}
}
