//
//  DateHandler.swift
//  Seasonal
//
//  Created by Clint Thomas on 28/8/20.
//  Copyright © 2020 Clint Thomas. All rights reserved.
//

import Foundation

struct DateHandler {

	func findMonthAndSeason() -> (Month, Season) {
		// find the current month and store the index
		let currentPageDate: [String] = Calendar.current.shortStandaloneMonthSymbols
		let dateFormatter: DateFormatter = DateFormatter()
		dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+8:00") as? TimeZone
		dateFormatter.dateFormat = "MMM"

		let today: Date = Date()
		let currentMonth: String = dateFormatter.string(from: today)
		let monthString: Month = Month.asArray[(currentPageDate.firstIndex(of: currentMonth) ?? 0) as Int]

		// Infinite CollectionView means the month in Month.asArray will be 1 less
		let month: Month = Month(rawValue: (monthString.rawValue + 1)) ?? .december

		switch month {
		case .december, .january, .february:
			return (month, .summer)

		case .march, .april, .may:
			return (month, .autumn)

		case .june, .july, .august:
			return (month, .winter)

		case .september, .october, .november:
			return (month, .spring)

		default:
			return (Month.december, .summer)
		}
	}
}
