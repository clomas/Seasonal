//
//  MainViewModel.swift
//  Seasonal
//
//  Created by Clint Thomas on 23/2/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import Foundation

enum Month: Int, CaseIterable {
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
}

final class MainViewModel: MenuBarDelegate, MonthSelectedDelegate {

	weak var coordinator: MainViewCoordinator?

	var viewDisplayed: ViewDisplayed

	var monthsProduce: [[ProduceModel]]
	var favouritesProduce: [ProduceModel]

	private let produceDataService: ProduceDataService

	var month: Month
	var previousMonth: Month // Keep track of - for animation
	var category: ViewDisplayed.ProduceCategory
	var searchString: String

	var reloadTableView = {}
	var updateMenuBar = {}

	init(monthsProduce: [[ProduceModel]],
		 favouritesProduce: [ProduceModel],
		 viewDisplayed: ViewDisplayed,
		 month: Month,
		 previousMonth: Month,
		 category: ViewDisplayed.ProduceCategory,
		 searchString: String,
		 dataService: ProduceDataService = ProduceDataService()) {

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
			self.viewDisplayed = .months
		}
		updateMenuBar()
		reloadTableView()
	}
	// TODO: 
	func likeToggle(id: Int, liked: Bool) {
		print("toggle = \(id) \(liked)" )
		// reference for favourites array manipulation
		var lastMonthIndex = 0
		var produceIndex = 0
		// update viewModel array
		var updateLikeTo = false

		if liked == false {
			updateLikeTo = true
		}

		for (monthIndex, monthProduce) in self.monthsProduce.enumerated() {
			if let likedProduceIndex = monthProduce.firstIndex(where: { $0.id == id }) {
				self.monthsProduce[monthIndex][likedProduceIndex].liked = updateLikeTo
				lastMonthIndex = monthIndex
				produceIndex = likedProduceIndex
 			}
		}

		func addRemoveFavourites() {
			if updateLikeTo == true {
				// get the liked produce, insert into array at the correct index by id
				let newFavourite = self.monthsProduce[lastMonthIndex][produceIndex]
				favouritesProduce.insert(newFavourite, at: favouritesProduce.firstIndex(where: {$0.produceName > newFavourite.produceName}) ?? favouritesProduce.endIndex)
			} else {
				favouritesProduce.removeAll {$0.id == self.monthsProduce[lastMonthIndex][produceIndex].id}
			}
		}
		// Call here to update before tableView updates
		addRemoveFavourites()

		// Update in CloudKit and on disk
		produceDataService.updateLike(id: id, liked: updateLikeTo)
		// Update data model for syncing between views
		coordinator?.updateDataModels(for: id, liked: updateLikeTo, from: .months)
	}

	func infoButtonTapped() {
		coordinator?.presentInfoViewController()
	}

//	func insertSorted<T: Comparable>( seq: inout [T], newItem item: T) {
//		let index = seq.reduce(0) { $1 < item ? $0 + 1 : $0 }
//		seq.insert(item, at: index)
//	}
}

extension Collection {
	func insertionIndex(of element: Self.Iterator.Element,
						using areInIncreasingOrder: (Self.Iterator.Element, Self.Iterator.Element) -> Bool) -> Index {
		return firstIndex(where: { !areInIncreasingOrder($0, element) }) ?? endIndex
	}
}

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

extension MainViewModel {

	// Filter by search fields and produce categories selected
	func filter(by searchString: String, of category: ViewDisplayed.ProduceCategory) -> [[ProduceModel]] {
		switch category {
		case .cancelled, .all:
			if searchString == "" {
				return self.monthsProduce
			} else {
				return self.monthsProduce.map({ return $0.filter({ $0.produceName.lowercased().contains(searchString.lowercased()) })})
			}
		case .fruit, .vegetables, .herbs:
			if searchString == "" {
				return self.monthsProduce.map({ return $0.filter({ $0.category == category })})
			} else {
				return self.monthsProduce.map({ return $0.filter({ $0.category == category &&
																	$0.produceName.lowercased().contains(searchString.lowercased()) })})
			}
		}
	}

	func filterFavourites(by searchString: String, category: ViewDisplayed.ProduceCategory) -> [ProduceModel] {
		switch category {
		case .cancelled, .all:
			if searchString == "" {

				return self.favouritesProduce.filter {$0.liked == true}
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
