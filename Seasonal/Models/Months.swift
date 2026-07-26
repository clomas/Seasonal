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

	static let currentPeriod: Months = Months(rawValue: Calendar.current.component(.month, from: Date())) ?? .december
    
    var title: String {
        switch self {
        case .january:
            "January"
        case .february:
            "February"
        case .march:
            "March"
        case .april:
            "April"
        case .may:
            "May"
        case .june:
            "June"
        case .july:
            "July"
        case .august:
            "August"
        case .september:
            "September"
        case .october:
            "October"
        case .november:
            "November"
        case .december:
            "December"
        }
    }

	var index: Int {
		rawValue - 1
	}

	var cacheKey: ProduceCacheKey {
		.month(self)
	}

	func contains(_ produce: Produce) -> Bool {
		produce.months?.contains(self) == true
	}

	var firstLetter: String {
		"\(self)".first?.uppercased() ?? ""
	}
}

