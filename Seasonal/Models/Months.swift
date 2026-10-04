//
//  Months.swift
//  Seasonal
//
//  Created by Clint Thomas on 20/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import Foundation

enum Months: Int, PeriodType, Codable {
	case january = 1
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

	static let currentPeriod = Months(containing: Date())

	init(containing date: Date, calendar: Calendar = .current) {
		self = Months(rawValue: calendar.component(.month, from: date)) ?? .december
	}

	var title: String {
		switch self {
		case .january: Strings.Month.january
		case .february: Strings.Month.february
		case .march: Strings.Month.march
		case .april: Strings.Month.april
		case .may: Strings.Month.may
		case .june: Strings.Month.june
		case .july: Strings.Month.july
		case .august: Strings.Month.august
		case .september: Strings.Month.september
		case .october: Strings.Month.october
		case .november: Strings.Month.november
		case .december: Strings.Month.december
		}
	}

	var index: Int {
		rawValue - 1
	}

	var cacheKey: ProduceCacheKey {
		.month(self)
	}

	var firstLetter: String {
		title.first.map(String.init) ?? ""
	}

	func contains(_ produce: Produce) -> Bool {
		produce.months?.contains(self) == true
	}
}
