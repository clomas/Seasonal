//
//  Produce.swift
//  Seasonal
//
//  Created by Clint Thomas on 20/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

class Produce: Identifiable {
	var id: Int?
	var name: String?
	var category: ProduceCategory?
	var imageName: String?
	var description: String? // Not implemented yet
	var months: [Months]?
	var seasons: [Seasons]?
	var liked: Bool?
}

extension Array where Element == Produce {

	/// Filters produce by period, category, and search. Works for any PeriodType.
	func filtered<Period: PeriodType>(
		by period: Period,
		category: ProduceCategory,
		search: String
	) -> [Produce] {
		self
			.filter { period.allCases.contains(period) && (category == .all || $0.category == category) }
			.filter { search.isEmpty || $0.name?.localizedCaseInsensitiveContains(search) == true }
	}
}

extension Array where Element == Produce {

	func sortIntoFavourites() -> [ProduceOld] {
		return self.map { ProduceOld(produce: $0) }.filter {
			$0.liked == true
		}
	}

	func sortIntoMonths() -> [[ProduceOld]] {
			// create array of 12 months
		var monthProduceArray: [[ProduceOld]] = .init(repeating: [], count: 12)

		for monthIndex in 0...11 {
			var monthArray: [ProduceOld] = [ProduceOld]()

			self.forEach({ (item: Produce) in

				if let month: Months = Months(rawValue: (monthIndex	+ 1)) {
					if item.months?.contains(month) == true {
						monthArray.append(ProduceOld(produce: item))
					}
				}
			})
			monthProduceArray[monthIndex] = monthArray
		}
		monthProduceArray.insert(monthProduceArray[11], at: 0)
		monthProduceArray.append(monthProduceArray[1])

		return monthProduceArray
	}
}
