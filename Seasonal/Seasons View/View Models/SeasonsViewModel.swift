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
	    case autumn = 1
	    case winter = 2
	    case spring = 3
	    case cancelled = 4
}

final class SeasonsViewModel: MenuBarDelegate {

	weak var coordinator: MainViewCoordinator?

	var produceData: [Season: [Produce]]

	private let produceDataService: ProduceDataService

	var season: Season
	var category: ViewDisplayed.ProduceCategory
	var searchString: String

	var reloadTableView: Closure = {}

	init(produceData: [Season: [Produce]],
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

	func menuBarWasTapped(at index: Int) {
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

			season = Season(rawValue: index) ?? .summer

		default:
			return
		}
		reloadTableView()
	}

	func updateTitle() -> String {
		return String(describing: season).createTitleString(with: category)
	}

	/// reference for favourites array manipulation
	/// produceDataService.updateLike(id: id, liked: liked)
	/// update viewModel array
	func likeToggle(id: Int, liked: Bool) {
		var updateLikeTo: Bool = liked

		if liked == false {
			updateLikeTo = true
		}

		// Update in CloudKit and on disk
		produceDataService.updateLike(id: id, liked: liked)

		for seasonProduce in produceData {
			let season: Season = seasonProduce.key

			if let index: Array<ProduceModel>.Index = produceData[season]?.firstIndex(where: { $0.id == id}) {
				produceData[season]?[index].liked = updateLikeTo
				#if DEBUG
				print(produceData[season]?[index].liked ?? "")
				#endif
			}
		}
		// The MainViewController has to know about liked produce
		// bubble up the id and like to coordinator
		coordinator?.updateDataModelsAndDatabase(for: id, liked: liked, from: .seasons)
	}

	func backButtonWasTapped() {
		coordinator?.seasonsBackButtonTapped()
	}

	func infoButtonWasTapped() {
		coordinator?.presentInfoViewController()
	}
}

extension Array where Element == ProduceModel {

	func sortIntoSeasons() -> [Season: [Produce]] {
		var seasonsArray: [Season: [Produce]] = [Season: [Produce]]()

		Season.asArray.forEach { (season: Season) in
			var seasonsProduce: [Produce] = [Produce]()

			if season != .cancelled {
				forEach({ item in
					if item.seasons.contains(season) {
						seasonsProduce.append(Produce(produce: item))
					}
				})
				seasonsArray[season] = seasonsProduce
			}
		}
		return seasonsArray
	}
}

extension SeasonsViewModel {

	func filter(by season: Season, matching searchString: String, of category: ViewDisplayed.ProduceCategory) -> [Produce] {
		guard let seasonData: [Produce] = produceData[season] else { return [Produce]() }

		switch category {
		case .cancelled, .all:
			if searchString == "" {
				return seasonData

			} else {
				return seasonData.filter { $0.produceName.lowercased().contains(searchString.lowercased()) }
			}
		case .fruit, .vegetables, .herbs:
			if searchString == "" {
				return seasonData.filter { $0.category == category }

			} else {
				return seasonData.filter { $0.category == category
					&& $0.produceName.lowercased().contains(searchString.lowercased())
				}
			}
		}
	}
}
