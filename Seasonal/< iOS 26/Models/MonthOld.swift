	//
	//  Months.swift
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

extension Calendar {

	func isDateInThisMonth(_ date: Date) -> Bool {
		isDate(date, equalTo: Date(), toGranularity: .month)
	}
}

// MARK: - Category mapping
extension ProduceCategory {
	var toOld: ViewDisplayed.ProduceCategory {
		switch self {
		case .all:       .all
		case .fruit:     .fruit
		case .vegetables: .vegetables
		case .herbs:      .herbs
				// extend if you have more
		}
	}
}

	// MARK: - Months mapping
extension Months {
	var toOld: MonthOld {
		switch self {
		case .january:    .january
		case .february:   .february
		case .march:      .march
		case .april:      .april
		case .may:        .may
		case .june:       .june
		case .july:       .july
		case .august:     .august
		case .september:  .september
		case .october:    .october
		case .november:   .november
		case .december:   .december
		}
	}
}

extension Array where Element == Months {
	var toOld: [MonthOld] { map(\.toOld) }
}

	// MARK: - Seasons mapping
extension Seasons {
	var toOld: SeasonsOld {
		switch self {
		case .summer: .summer
		case .autumn: .autumn
		case .winter: .winter
		case .spring: .spring
		default: .cancelled
		}
	}
}

extension Array where Element == Seasons {
	var toOld: [SeasonsOld] { map(\.toOld) }
}
