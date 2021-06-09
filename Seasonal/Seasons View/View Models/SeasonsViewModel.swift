//
//  SeasonsViewModel.swift
//  Seasonal
//
//  Created by Clint Thomas on 23/2/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import Foundation

enum Season: Int, CaseIterable {
	    case summer = 0
	    case autumn
	    case winter
	    case spring
	    case cancelled
}

final class SeasonsViewModel: MenuBarDelegate {

	weak var coordinator: MainViewCoordinator?

	var produceData: [Season: [ProduceModel]]

	private let produceDataService: ProduceDataService

	var season: Season
	var category: ViewDisplayed.ProduceCategory
	var searchString: String

	var reloadTableView = {}

	init(produceData: [Season: [ProduceModel]],
		 season: Season,
		 category: ViewDisplayed.ProduceCategory,
		 searchString: String,
		 dataService: ProduceDataService = ProduceDataService()) {
		self.produceData = produceData
		self.season = season
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
		case ViewDisplayed.ProduceCategory.cancelled.rawValue:
			category = .cancelled
		case Season.summer.rawValue,
			 Season.autumn.rawValue,
			 Season.winter.rawValue,
			 Season.spring.rawValue:
			self.season = Season.init(rawValue: index)!
		default:
			return
		}
		reloadTableView()
	}

	func updateTitle() -> String {
		return String(describing: season).createTitleString(with: category)
	}

	// TODO:
	func likeToggle(id: Int, liked: Bool) {
		print(liked)

		// reference for favourites array manipulation
	//	var lastMonthIndex = 0
	//	var produceIndex = 0
		// produceDataService.updateLike(id: id, liked: liked)
		// update viewModel array
		var updateLikeTo = false

		if liked == false {
			updateLikeTo = true
		}

		// Update in CloudKit and on disk
		produceDataService.updateLike(id: id, liked: liked)

		for seasonProduce in self.produceData {
			let season = seasonProduce.key
			if let index = self.produceData[season]?.firstIndex(where: { $0.id == id}) {
				self.produceData[season]?[index].liked = updateLikeTo
				print(self.produceData[season]?[index].liked ?? "")
			}
		}
		// The MainViewController has to know about liked produce
		// bubble up the id and like to coordinator
		coordinator?.updateDataModels(for: id, liked: liked)

//		func addRemoveFavourites() {
//			if liked == true {
//				// get the liked produce, insert into array at the correct index by id
//				let newFavourite = self.monthsProduce[lastMonthIndex][produceIndex]
//				favouritesProduce.insert(newFavourite, at: favouritesProduce.firstIndex(where: {$0.produceName > newFavourite.produceName}) ?? favouritesProduce.endIndex)
//			} else {
//				favouritesProduce.removeAll {$0.id == self.monthsProduce[lastMonthIndex][produceIndex].id}
//			}
//		}
//		addRemoveFavourites()

	}

	func backButtonTapped() {
		coordinator?.seasonsBackButtonTapped()
	}

	func infoButtonTapped() {
		coordinator?.presentInfoViewController()
	}
}

extension Array where Element == Produce {

	func sortIntoSeasons() -> [Season: [ProduceModel]] {
		var seasonsArray = [Season: [ProduceModel]]()

		Season.asArray.forEach { season in
			var seasonsProduce = [ProduceModel]()
			if season != Season.cancelled {
				self.forEach({ item in
					if item.seasons.contains(season) {
						seasonsProduce.append(ProduceModel.init(produce: item))
					}
				})
				seasonsArray[season] = seasonsProduce
			}
		}
		return seasonsArray
	}
}

extension SeasonsViewModel {

	func filter(by season: Season, matching searchString: String, of category: ViewDisplayed.ProduceCategory) -> [ProduceModel] {
		if let seasonData = produceData[season] {
			switch category {
			case .cancelled, .all:
				if searchString == "" {
					return seasonData
				} else {
					return seasonData.filter({ $0.produceName.lowercased().contains(searchString.lowercased())
					})
				}
			case .fruit, .vegetables, .herbs:
				if searchString == "" {
					return seasonData.filter({ $0.category == category })
				} else {
					return seasonData.filter({ $0.category == category &&
																$0.produceName.lowercased().contains(searchString.lowercased())
					})
				}
			}
		} else {
			return [ProduceModel]()
		}
	}
}
