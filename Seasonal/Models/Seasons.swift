//
//  Seasons.swift
//  Seasonal
//
//  Created by Clint Thomas on 18/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import Foundation

enum Seasons: Int, PeriodType, Codable {
	case summer = 0
	case autumn
	case winter
	case spring

	static var currentPeriod: Seasons {
		Seasons(containing: .currentPeriod)
	}

	/// Southern-hemisphere seasons.
	init(containing month: Months) {
		switch month {
		case .march, .april, .may: self = .autumn
		case .june, .july, .august: self = .winter
		case .september, .october, .november: self = .spring
		case .december, .january, .february: self = .summer
		}
	}

	var title: String {
		switch self {
		case .summer: Strings.Season.summer
		case .autumn: Strings.Season.autumn
		case .winter: Strings.Season.winter
		case .spring: Strings.Season.spring
		}
	}

	var index: Int {
		rawValue
	}

	var cacheKey: ProduceCacheKey {
		.season(self)
	}

	/// The code used for this season in CloudKit records.
	var shortName: String {
		switch self {
		case .summer: "sum"
		case .autumn: "aut"
		case .winter: "win"
		case .spring: "spr"
		}
	}

	func contains(_ produce: Produce) -> Bool {
		produce.seasons?.contains(self) == true
	}
}
