//
//  MainViewModel.swift
//  Seasonal
//
//  Created by Clint Thomas on 23/2/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import Foundation

typealias Closure = () -> Void

final class MainViewModel: MenuBarDelegate, MonthSelectedDelegate {

	private let produceDataService: ProduceDataService

	var viewDisplayed: ViewDisplayed
	var allMonthsAndTheirProduce: [[Produce]]?
	var favouritesProduce: [Produce]?
	var monthToDisplay: Month
	var thisMonthForProduceCell: Month // For displaying the circle in cell of current month.
	var previousMonth: Month // Keep track of - for animation
	var category: ViewDisplayed.ProduceCategory
	var searchString: String
	var numberOfRows: Int {

		switch viewDisplayed {
		case .favourites:
			return filterFavourites(by: searchString, category: category).count
		case .months:
			return filter(by: searchString, of: category)[monthToDisplay.rawValue].count
		default:
			return 0
		}
	}

	var reloadTableView: Closure = {}
	var updateMenuBar: Closure = {}

	weak var coordinator: MainViewCoordinator?

	init(monthsProduce: [[Produce]]?,
		 favouritesProduce: [Produce]?,
		 viewDisplayed: ViewDisplayed,
		 monthToDisplay: Month,
		 previousMonth: Month,
		 thisMonthForProduceCell: Month,
		 category: ViewDisplayed.ProduceCategory,
		 searchString: String,
		 dataService: ProduceDataService = ProduceDataService()
	) {
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

	var navigationBarTitleString: String {
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

	func menuBarWasTapped(at index: Int) {
		switch index {
		case ViewDisplayed.ProduceCategory.fruit.rawValue,
			ViewDisplayed.ProduceCategory.vegetables.rawValue,
			ViewDisplayed.ProduceCategory.herbs.rawValue:

			category = ViewDisplayed.ProduceCategory(rawValue: index) ?? .all
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
			coordinator?.menuBarTappedWasForNavigation(at: index)

		default:
			if let view: ViewDisplayed = ViewDisplayed(rawValue: index) {
				viewDisplayed = view
			}
		}
		reloadTableView()
	}

		/// Update Month after another ViewController was displayed.
		/// - Parameter month: month can be nil - if it is no need to update.
	func updateMonth(to month: Month?) {
		if let month: Month = month {
			monthToDisplay = month
			viewDisplayed = .months
		}
		updateMenuBar()
		reloadTableView()
	}

	func infoButtonTapped() {
		coordinator?.presentInfoViewController()
	}

	func likeToggle(id: Int, liked: Bool) {
		let updateLikeTo: Bool = liked == false ? true : false
		var produceToToggle: Produce?

		if let produce: [[Produce]] = allMonthsAndTheirProduce {
			for (monthIndex, monthProduce) in produce.enumerated() {

				if let likedProduceIndex: Array<Produce>.Index = monthProduce.firstIndex(where: { $0.id == id }) {
					allMonthsAndTheirProduce?[monthIndex][likedProduceIndex].liked = updateLikeTo
					produceToToggle = allMonthsAndTheirProduce?[monthIndex][likedProduceIndex]
				}
			}
		}

		updateFavouritesArray(produce: produceToToggle, liked: updateLikeTo)
			// Update in CloudKit and on disk
		produceDataService.updateLike(id: id, liked: updateLikeTo)
			// Update data model for syncing between views
		coordinator?.updateDataModelsAndDatabase(for: id, liked: updateLikeTo, from: .months)
	}

	private func updateFavouritesArray(produce: Produce?, liked: Bool) {
		if liked == true {
			if let selectedProduce: Produce = produce {
				favouritesProduce?.insert(selectedProduce, at: 0)
				favouritesProduce = favouritesProduce?.sorted(by: { $0.produceName < $1.produceName })
			}
		} else {
			favouritesProduce = favouritesProduce?.filter { $0.id != produce?.id }
		}
	}
}

extension MainViewModel {

	// Filter by search fields and produce categories selected
	func filter(by searchString: String, of category: ViewDisplayed.ProduceCategory) -> [[Produce]] {
		guard let monthsProduce: [[Produce]] = allMonthsAndTheirProduce else { return [] }

		switch category {
		case .cancelled, .all:
			if searchString == "" {
				return monthsProduce
			} else {
				return monthsProduce.map { $0.filter {
					$0.produceName.lowercased().contains(searchString.lowercased()) }
				}
			}
		case .fruit, .vegetables, .herbs:
			if searchString == "" {
				return monthsProduce.map { $0.filter { $0.category == category }}
			} else {
				return monthsProduce.map { $0.filter {
					$0.category == category && $0.produceName.lowercased().contains(searchString.lowercased()) }
				}
			}
		}
	}

	func filterFavourites(by searchString: String?, category: ViewDisplayed.ProduceCategory) -> [Produce] {
		guard let favouritesProduce else { return [] }

		switch category {
		case .cancelled, .all:
			guard let searchString, searchString != "" else {
				return favouritesProduce
			}

			return favouritesProduce.filter { $0.produceName.lowercased().contains(searchString.lowercased()) }

		case .fruit, .vegetables, .herbs:
			guard let searchString, searchString != "" else {
				return favouritesProduce
			}

			return favouritesProduce.filter { $0.category == category
				&& $0.produceName.lowercased().contains(searchString.lowercased())
			}
		}
	}
}
