//
//  _SeasonsViewModel.swift
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

final class _SeasonsViewModel: _MenuBarDelegate {

	weak var coordinator: _MainViewCoordinator?
	var produceData: [Season:[_ProduceModel]]
	var season: Season
	var category: ViewDisplayed.ProduceCategory
	var searchString: String
	var reloadTableView = {}

	init(produceData: [Season:[_ProduceModel]],
		 season: Season,
		 category: ViewDisplayed.ProduceCategory,
		 searchString: String
	) {
		self.produceData = produceData
		self.season = season
		self.category = category
		self.searchString = searchString
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

	func menuBarScrollFinished() {
		//<#code#>Butt
	}


	func likeToggle(id: Int, liked: Bool) {

		// UP TO HERE - likeToggle
//		// reference for favourites array manipulation
//		var lastMonthIndex = 0
//		var produceIndex = 0
//		produceDataService.updateLike(id: id, liked: liked)
//		// update viewModel array
//		for (monthIndex, month) in self.monthsProduce.enumerated() {
//			if let likedProduceIndex = month.firstIndex(where: { $0.id == id }) {
//				self.monthsProduce[monthIndex][likedProduceIndex].liked = liked
//				lastMonthIndex = monthIndex
//				produceIndex = likedProduceIndex
//			} else {
//				print("like index not found")
//			}
//		}
//
//		func addRemoveFavourites() {
//			if liked == true {
//				favouritesProduce.append(self.monthsProduce[lastMonthIndex][produceIndex])
//			} else {
//				favouritesProduce.removeAll{$0.id == self.monthsProduce[lastMonthIndex][produceIndex].id}
//			}
//
		
	}

	func backButtonTapped() {
		coordinator?.seasonsBackButtonTapped()
	}

	func infoButtonTapped() {
		coordinator?.presentInfoViewController()
	}
}

extension Array where Element == Produce {
	
	func sortIntoSeasons() -> [Season:[_ProduceModel]] {
		var seasonsArray = [Season: [_ProduceModel]]()

		Season.asArray.forEach { season in
			var seasonsProduce = [_ProduceModel]()
			if season != Season.cancelled {
				self.forEach({ item in
					if item.seasons.contains(season) {
						seasonsProduce.append(_ProduceModel.init(produce: item))
					}
				})
				seasonsArray[season] = seasonsProduce
			}
		}
		return seasonsArray
	}
}

extension _SeasonsViewModel {

	func filter(by season: Season, matching searchString: String,of category: ViewDisplayed.ProduceCategory) -> [_ProduceModel] {
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
			return [_ProduceModel]()
		}
	}
}
