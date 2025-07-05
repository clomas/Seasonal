//
//  Extension-Produce-Array.swift
//  Seasonal
//
//  Created by Clint Thomas on 8/4/2023.
//  Copyright © 2023 Clint Thomas. All rights reserved.
//

import Foundation

// Sort produce into viewModel arrays

extension Array where Element == ProduceModel {

	func sortIntoFavourites() -> [Produce] {
		return self.map { Produce(produce: $0) }.filter {
			$0.liked == true
		}
	}

	func sortIntoMonths() -> [[Produce]] {
			// create array of 12 months
		var monthProduceArray: [[Produce]] = .init(repeating: [], count: 12)

		for monthIndex in 0...11 {
			var monthArray: [Produce] = [Produce]()

			self.forEach({ (item: ProduceModel) in

				if let month: Month = Month(rawValue: (monthIndex	+ 1)) {
					if item.months.contains(month) {
						monthArray.append(Produce(produce: item))
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
