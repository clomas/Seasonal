//
//  MainViewModel.swift
//  Seasonal
//
//  Created by Clint Thomas on 23/2/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import Foundation

final class MainViewModel: MenuBarDelegate, MonthSelectedDelegate {

	private let produceDataService: ProduceDataService

	var viewDisplayed: ViewDisplayed
	var allMonthsAndTheirProduce: [[ProduceModel]]?
	var favouritesProduce: [ProduceModel]?
	var monthToDisplay: Month
	var thisMonthForProduceCell: Month // For displaying the circle in cell of current month.
	var previousMonth: Month // Keep track of - for animation
	var category: ViewDisplayed.ProduceCategory
	var searchString: String
	var numberOfRows: Int {

		switch viewDisplayed {
		case .favourites:
			return filter(by: searchString, of: category).count
		case .months:
			return filter(by: searchString, of: category)[monthToDisplay.rawValue].count
		default:
			return 0
		}
	}

	var reloadTableView = {}
	var updateMenuBar = {}

	weak var coordinator: MainViewCoordinator?

	init(monthsProduce: [[ProduceModel]]?,
		 favouritesProduce: [ProduceModel]?,
		 viewDisplayed: ViewDisplayed,
		 monthToDisplay: Month,
		 previousMonth: Month,
		 thisMonthForProduceCell: Month,
		 category: ViewDisplayed.ProduceCategory,
		 searchString: String,
		 dataService: ProduceDataService = ProduceDataService()) {

		self.allMonthsAndTheirProduce = monthsProduce
		self.favouritesProduce = favouritesProduce
		self.viewDisplayed = viewDisplayed
		self.monthToDisplay = monthToDisplay
		self.previousMonth = monthToDisplay
		self.thisMonthForProduceCell = thisMonthForProduceCell
		self.category = category
		self.searchString = searchString
		self.produceDataService = dataService
	}

	func menuBarWasTapped(at index: Int) {
		switch index {
		case ViewDisplayed.ProduceCategory.fruit.rawValue,
			 ViewDisplayed.ProduceCategory.vegetables.rawValue,
			 ViewDisplayed.ProduceCategory.herbs.rawValue:
			category = ViewDisplayed.ProduceCategory.init(rawValue: index) ?? .all
			reloadTableView()
		case ViewDisplayed.ProduceCategory.cancelled.rawValue,
			 ViewDisplayed.ProduceCategory.all.rawValue:
			category = .cancelled
			reloadTableView()
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
			return String(describing: monthToDisplay).createTitleString(with: category)
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
			monthToDisplay = month
			viewDisplayed = .months
		}
		updateMenuBar()
		reloadTableView()
	}

	func likeToggle(id: Int, liked: Bool) {
//		var lastMonthIndex = 0
//		var produceIndex = 0
// TODO: this?
//		var updateLikeTo = false
//
//		if liked == false {
//			updateLikeTo = true
//		}
		var produceToToggle: ProduceModel?

		if var produce: [[ProduceModel]] = allMonthsAndTheirProduce, var favourites: [ProduceModel] = favouritesProduce {

			for (monthIndex, monthProduce) in produce.enumerated() {

				if let likedProduceIndex = monthProduce.firstIndex(where: { $0.id == id }) {
					produceToToggle = produce[monthIndex][likedProduceIndex]
					produce[monthIndex][likedProduceIndex].liked = liked
//					lastMonthIndex = monthIndex
//					produceIndex = likedProduceIndex
				}
			}

			if let selectedProduce: ProduceModel = produceToToggle, liked == true {
				// get the liked produce, insert into array at the correct index by id

//				let newFavourite = monthsProduce?[lastMonthIndex][produceIndex]

				favourites.insert(selectedProduce, at: favourites.firstIndex(where: { $0.produceName > selectedProduce.produceName }) ?? favourites.endIndex)
			} else {
				favourites.removeAll { $0.id == produceToToggle?.id }
			}
		}

		// Update in CloudKit and on disk
		produceDataService.updateLike(id: id, liked: liked)
		// Update data model for syncing between views
		coordinator?.updateDataModels(for: id, liked: liked, from: .months)
	}

	func infoButtonTapped() {
		coordinator?.presentInfoViewController()
	}
}

extension Collection {
	func insertionIndex(of element: Self.Iterator.Element,
						using areInIncreasingOrder: (Self.Iterator.Element, Self.Iterator.Element) -> Bool) -> Index {
		return firstIndex(where: { !areInIncreasingOrder($0, element) }) ?? endIndex
	}
}

extension MainViewModel {

	// Filter by search fields and produce categories selected
	func filter(by searchString: String, of category: ViewDisplayed.ProduceCategory) -> [[ProduceModel]] {
		guard let monthsProduce: [[ProduceModel]] = allMonthsAndTheirProduce else { return [] }

		switch category {
		case .cancelled, .all:
			if searchString == "" {
				return monthsProduce
			} else {
				return monthsProduce.map({ $0.filter({ $0.produceName.lowercased().contains(searchString.lowercased()) })})
			}
		case .fruit, .vegetables, .herbs:
			if searchString == "" {
				return monthsProduce.map({ $0.filter({ $0.category == category })})
			} else {
				return monthsProduce.map({ return $0.filter({ $0.category == category &&
																	$0.produceName.lowercased().contains(searchString.lowercased()) })})
			}
		}
	}

	func filterFavourites(by searchString: String?, category: ViewDisplayed.ProduceCategory) -> [ProduceModel] {
		guard let produce: [ProduceModel] = favouritesProduce else { return [] }

		switch category {
		case .cancelled, .all:
			guard let searchString else {
				return produce.filter { $0.liked == true }
			}

			return produce.filter { $0.produceName.lowercased().contains(searchString.lowercased()) }

		case .fruit, .vegetables, .herbs:
			guard let searchString else {
				return produce.filter { $0.category == category }
			}

			return produce.filter { $0.category == category &&
											   $0.produceName.lowercased().contains(searchString.lowercased())

			}
		}
	}
}
