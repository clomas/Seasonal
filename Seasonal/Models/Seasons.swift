//
//  Seasons.swift
//  Seasonal
//
//  Created by Clint Thomas on 18/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

enum Seasons: Int, PeriodType {
	case summer = 0
	case autumn
	case winter
	case spring

	static var currentPeriod: Seasons {
		switch Calendar.current.component(.month, from: Date()) {
		case 12, 1, 2:
			return .summer
		case 3, 4, 5:
			return .autumn
		case 6, 7, 8:
			return .winter
		case 9, 10, 11:
			return .spring
		default:
			return .summer
		}
	}

    var title: String {
        switch self {
        case .summer:
            "Summer"
        case .autumn:
            "Autumn"
        case .winter:
            "Winter"
        case .spring:
            "Spring"
        }
    }

	var image: Image {
		.seasons
	}

	var index: Int {
		rawValue
	}

	var cacheKey: ProduceCacheKey {
		.season(self)
	}

	func contains(_ produce: Produce) -> Bool {
		produce.seasons?.contains(self) == true
	}

	var shortName: String {
		switch self {
		case .summer: return "sum"
		case .autumn: return "aut"
		case .winter: return "win"
		case .spring: return "spr"
		}
	}
}
