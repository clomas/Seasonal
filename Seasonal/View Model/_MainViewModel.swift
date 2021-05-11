//
//  _MainViewModel.swift
//  Seasonal
//
//  Created by Clint Thomas on 23/2/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import Foundation


enum Month: Int, CaseIterable {
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
}

final class _MainViewModel: _MenuBarDelegate, MonthSelectedDelegate {

	weak var coordinator: _MainViewCoordinator?
	var monthsProduce: [[_ProduceModel]]
	var favouritesProduce: [_ProduceModel]
	var viewDisplayed: ViewDisplayed
	var month: Month
	var previousMonth: Month // Keep track of - for animation
	var category: ViewDisplayed.ProduceCategory
	var searchString: String
	var reloadTableView = {}
	var updateMenuBar = {}
	
	private let produceDataService: _ProduceDataService

	init(monthsProduce: [[_ProduceModel]],
		 favouritesProduce: [_ProduceModel],
		 viewDisplayed: ViewDisplayed,
		 month: Month,
		 previousMonth: Month,
		 category: ViewDisplayed.ProduceCategory,
		 searchString: String,
		 dataService: _ProduceDataService = _ProduceDataService()) {

		self.monthsProduce = monthsProduce
		self.favouritesProduce = favouritesProduce
		self.viewDisplayed = viewDisplayed
		self.month = month
		self.previousMonth = month
		self.category = category
		self.searchString = searchString
		self.produceDataService = dataService
	}

	func menuBarTapped(at index: Int) {
		switch index {
		case ViewDisplayed.ProduceCategory.fruit.rawValue,
			 ViewDisplayed.ProduceCategory.vegetables.rawValue,
			 ViewDisplayed.ProduceCategory.herbs.rawValue:
			 category = ViewDisplayed.ProduceCategory.init(rawValue: index) ?? .all
		case ViewDisplayed.ProduceCategory.cancelled.rawValue,
			 ViewDisplayed.ProduceCategory.all.rawValue:
			 category = .cancelled
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

	func updateTitle() -> String {
		switch viewDisplayed {
		case .monthPicker:
			return Constants.selectAMonth
		case .months:
			return String(describing: month).createTitleString(with: category)
		case .favourites:
			return Constants.favourites.createTitleString(with: category)
		default:
			return Constants.seasonal
		}
	}


	/// Update Month after another ViewController was displayed.
	/// - Parameter month: month can be nil - if it is no need to update.
	func updateMonth(to month: Month?) {
		if let month = month {
			self.month = month
		}
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
		print(liked)
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
 			}
		}

		func addRemoveFavourites() {
			if liked == true {
				// get the liked produce, insert into array at the correct index by id
				let newFavourite = self.monthsProduce[lastMonthIndex][produceIndex]
				favouritesProduce.insert(newFavourite, at: favouritesProduce.firstIndex(where: {$0.produceName > newFavourite.produceName}) ?? favouritesProduce.endIndex)

				
			} else {
				favouritesProduce.removeAll{$0.id == self.monthsProduce[lastMonthIndex][produceIndex].id}
			}
		}
		addRemoveFavourites()
	}

	func infoButtonTapped() {
		coordinator?.presentInfoViewController()
	}

	func insertSorted<T: Comparable>( seq: inout [T], newItem item: T) {
		let index = seq.reduce(0) { $1 < item ? $0 + 1 : $0 }
		seq.insert(item, at: index)
	}

}

extension Collection {
	func insertionIndex(of element: Self.Iterator.Element,
						using areInIncreasingOrder: (Self.Iterator.Element, Self.Iterator.Element) -> Bool) -> Index {
		return firstIndex(where: { !areInIncreasingOrder($0, element) }) ?? endIndex
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

	func filter(by searchString: String, of category: ViewDisplayed.ProduceCategory) -> [[_ProduceModel]] {
		switch category {
		case .cancelled, .all:
			if searchString == "" {
				return self.monthsProduce
			} else {
				return self.monthsProduce.map ({ return $0.filter({ $0.produceName.lowercased().contains(searchString.lowercased()) })})
			}
		case .fruit, .vegetables, .herbs:
			if searchString == "" {
				return self.monthsProduce.map ({ return $0.filter({ $0.category == category })})
			} else {
				return self.monthsProduce.map ({ return $0.filter({ $0.category == category &&
																	$0.produceName.lowercased().contains(searchString.lowercased()) })})
			}
		}
	}

	func filterFavourites(by searchString: String, category: ViewDisplayed.ProduceCategory) -> [_ProduceModel] {
		switch category {
		case .cancelled, .all:
			if searchString == "" {
				return self.favouritesProduce.filter{$0.liked == true}
			} else {
				return self.favouritesProduce.filter({ $0.produceName.lowercased().contains(searchString.lowercased()) })
			}
		case .fruit, .vegetables, .herbs:
			if searchString == "" {
				return self.favouritesProduce.filter({ $0.category == category })
			} else {
				return self.favouritesProduce.filter({ $0.category == category &&
													   $0.produceName.lowercased().contains(searchString.lowercased()) })
			}
		}
	}
}

