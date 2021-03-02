//
//  _MonthsViewModel.swift
//  Seasonal
//
//  Created by Clint Thomas on 23/2/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import Foundation

final class _MonthsViewModel {

	var coordinator: _MainViewCoordinator?
	var viewModel = [[_ProduceModel]]()
	var viewDisplayed: ViewDisplayed
	var filter: ViewDisplayed.ProduceFilter
	var month: Month
	private let produceDataService: _ProduceDataService

	init(produceData: [Produce], viewDisplayed: ViewDisplayed, filter: ViewDisplayed.ProduceFilter,  month: Month, dataService: _ProduceDataService = _ProduceDataService()) {
		self.viewDisplayed = viewDisplayed
		self.filter = filter
		self.month = month
		self.produceDataService = dataService
		self.viewModel = sortViewModel(produce: produceData)
	}

	func sortViewModel(produce: [Produce]) -> [[_ProduceModel]] {
		var monthProduceArr: [[_ProduceModel]] = .init(repeating: [], count: 12)

		for monthIndex in 0...11 {
			var monthArray = [_ProduceModel]()
			produce.forEach({ item in
				if item.months.contains(Month.init(rawValue: monthIndex)!) {
					monthArray.append(_ProduceModel.init(produce: item))
				}
			})
			monthProduceArr[monthIndex] = monthArray
		}

		return monthProduceArr
	}

	func menuBarTapped() {

		// update this to curr menu bar selection.
//		appStatus.viewDisplayed = .months


	}

//	func updateVisibleMonth(to visibleMonth: Month) {
//		if appStatus.month != visibleMonth {
//			appStatus.month = visibleMonth
//		}
//	}

	func likeToggle(id: Int, liked: Bool) {

		produceDataService.updateLike(id: id, liked: liked)


		// TODO: Test if I need this? I think I will need to reload when like is tapped

		// not sure
		
//		for (monthIndex, month) in self.viewModel.enumerated() {
//
//			if let likedProduceIndex = month.firstIndex(where: { $0.id == id }) {
//				self.viewModel[monthIndex][likedProduceIndex].liked = liked
//			} else {
//				print("like index not found")
//			}
//		}

	}
}

extension _MonthsViewModel {

	func filter(by searchString: String, of filter: ViewDisplayed.ProduceFilter) -> [[_ProduceModel]] {
		switch filter {
		case .cancelled, .all:
			if searchString == "" {
				return self.viewModel
			} else {
				return self.viewModel.map ({ return $0.filter({ $0.produceName?.lowercased().contains(searchString.lowercased()) ?? false})})
			}
		case .fruit, .vegetables, .herbs:
			if searchString == "" {
				return self.viewModel.map ({ return $0.filter({ $0.category == filter })})
			} else {
				return self.viewModel.map ({ return $0.filter({ $0.category == filter && $0.produceName?.lowercased().contains(searchString.lowercased()) ?? false})})
			}
		}
	}
}
