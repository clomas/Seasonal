//
//  _MainViewModel.swift
//  Seasonal
//
//  Created by Clint Thomas on 23/2/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import Foundation

final class _MainViewModel: _MenuBarDelegate, MonthSelectedDelegate {

	var coordinator: _MainViewCoordinator?
	var monthsProduce: [[_ProduceModel]]
	var favouritesProduce: [_ProduceModel]
	var viewDisplayed: ViewDisplayed
	var month: Month
	var filter: ViewDisplayed.ProduceFilter
	var searchString: String
	var reloadTableView = {}
	var updateMenuBar = {}
	//var updateMenuBar: (Month) -> () = {_ in }

	
	private let produceDataService: _ProduceDataService

	init(monthsProduce: [[_ProduceModel]],
		 favouritesProduce: [_ProduceModel],
		 viewDisplayed: ViewDisplayed,
		 month: Month,
		 filter: ViewDisplayed.ProduceFilter,
		 searchString: String,
		 dataService: _ProduceDataService = _ProduceDataService()) {

		self.monthsProduce = monthsProduce
		self.favouritesProduce = favouritesProduce
		self.viewDisplayed = viewDisplayed
		self.month = month
		self.filter = filter
		self.searchString = searchString
		self.produceDataService = dataService
	}

	func menuBarTapped(at index: Int) {
		//coordinator?.menuBarTapped(at: index)
		// the index is a filter
		switch index {
		case ViewDisplayed.ProduceFilter.fruit.rawValue,
			 ViewDisplayed.ProduceFilter.vegetables.rawValue,
			 ViewDisplayed.ProduceFilter.herbs.rawValue:
			filter = ViewDisplayed.ProduceFilter.init(rawValue: index) ?? .all
		case ViewDisplayed.ProduceFilter.cancelled.rawValue:
			filter = .cancelled
		// navigation
		case ViewDisplayed.monthPicker.rawValue,
			 ViewDisplayed.seasons.rawValue:
			// only need this delegate if monthPicker is initialised
			coordinator?.monthSelectedDelegate = self
			coordinator?.menuBarTappedForNavigation(at: index)
		default:
			if let view = ViewDisplayed.init(rawValue: index) {
				viewDisplayed = view
			}
		}
		reloadTableView()
	}

	func updateMonth(to month: Month) {
		self.month = month
		updateMenuBar()
		reloadTableView()
	}

	func menuBarScrollFinished() {
		// up to here
	}

//	func updateVisibleMonth(to visibleMonth: Month) {
//		if appStatus.month != visibleMonth {
//			appStatus.month = visibleMonth
//		}
//	}

	func likeToggle(id: Int, liked: Bool) {
		// reference for favourites array manipulation
		var lastMonthIndex = 0
		var produceIndex = 0
		produceDataService.updateLike(id: id, liked: liked)
		// update viewModel array
		for (monthIndex, month) in self.monthsProduce.enumerated() {
			if let likedProduceIndex = month.firstIndex(where: { $0.id == id }) {
				self.monthsProduce[monthIndex][likedProduceIndex].liked = liked
				lastMonthIndex = monthIndex
				produceIndex = likedProduceIndex
 			} else {
				print("like index not found")
			}
		}

		func addRemoveFavourites() {
			if liked == true {
				favouritesProduce.append(self.monthsProduce[lastMonthIndex][produceIndex])
			} else {
				favouritesProduce.removeAll{$0.id == self.monthsProduce[lastMonthIndex][produceIndex].id}
			}
		}
	}
}

// Sort produce into viewModel arrays

extension Array where Element == Produce {

	func sortIntoFavourites() -> [_ProduceModel] {
		return self.map{_ProduceModel.init(produce: $0)}.filter {
			$0.liked == true
		}
	}

	func sortIntoMonths() -> [[_ProduceModel]] {
		// create array of 12 months
		var monthProduceArray: [[_ProduceModel]] = .init(repeating: [], count: 12)

		for monthIndex in 0...11 {
			var monthArray = [_ProduceModel]()
			self.forEach({ item in
				if item.months.contains(Month.init(rawValue: monthIndex)!) {
					monthArray.append(_ProduceModel.init(produce: item))
				}
			})
			monthProduceArray[monthIndex] = monthArray
		}
		return monthProduceArray
	}
}

// filter by search fields and produce categories selected

extension _MainViewModel {

	func filter(by searchString: String, of filter: ViewDisplayed.ProduceFilter) -> [[_ProduceModel]] {
		switch filter {
		case .cancelled, .all:
			if searchString == "" {
				return self.monthsProduce
			} else {
				return self.monthsProduce.map ({ return $0.filter({ $0.produceName?.lowercased().contains(searchString.lowercased()) ?? false})})
			}
		case .fruit, .vegetables, .herbs:
			if searchString == "" {
				return self.monthsProduce.map ({ return $0.filter({ $0.category == filter })})
			} else {
				return self.monthsProduce.map ({ return $0.filter({ $0.category == filter && $0.produceName?.lowercased().contains(searchString.lowercased()) ?? false})})
			}
		}
	}

	func filterFavourites(by searchString: String, filter: ViewDisplayed.ProduceFilter) -> [_ProduceModel] {
		switch filter {
		case .cancelled, .all:
			if searchString == "" {
				return self.favouritesProduce.filter{$0.liked == true}
			} else {
				return self.favouritesProduce.filter({ $0.produceName?.lowercased().contains(searchString.lowercased()) ?? false})
			}
		case .fruit, .vegetables, .herbs:
			if searchString == "" {
				return self.favouritesProduce.filter({ $0.category == filter })
			} else {
				return self.favouritesProduce.filter({ $0.category == filter &&
												$0.produceName?.lowercased().contains(searchString.lowercased()) ?? false})
			}
		}
	}
}
