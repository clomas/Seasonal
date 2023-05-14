//
//  Extension-Produce-Array.swift
//  Seasonal
//
//  Created by Clint Thomas on 8/4/2023.
//  Copyright © 2023 Clint Thomas. All rights reserved.
//

import Foundation

// Sort produce into viewModel arrays

extension Array where Element == Produce {

	func sortIntoFavourites() -> [ProduceModel] {
		return self.map {ProduceModel.init(produce: $0)}.filter {
			$0.liked == true
		}
	}

	func sortIntoMonths() -> [[ProduceModel]] {
			// create array of 12 months
		var monthProduceArray: [[ProduceModel]] = .init(repeating: [], count: 12)

		for monthIndex in 0...11 {
			var monthArray = [ProduceModel]()
			self.forEach({ item in

				if let month = Month.init(rawValue: (monthIndex	+ 1)) {
					if item.months.contains(month) {
						monthArray.append(ProduceModel.init(produce: item))
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
