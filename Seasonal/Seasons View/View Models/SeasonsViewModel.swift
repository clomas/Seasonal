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

	private let produceDataService: ProduceDataService

	weak var coordinator: MainViewCoordinator?

	var produceData: [Season: [Produce]]
	var season: Season
	var category: ViewDisplayed.ProduceCategory

	var seasonProduceToDisplay: [Produce]? {
		didSet {
			numberOfRows = seasonProduceToDisplay?.count ?? 0
		}
	}
	var searchString: String
	var numberOfRows: Int?

	var reloadTableView: Closure = {}

	init(produceData: [Season: [Produce]],
		 season: Season,
		 category: ViewDisplayed.ProduceCategory,
		 searchString: String,
		 dataService: ProduceDataService = ProduceDataService()) {
		self.produceData = produceData
		self.seasonProduceToDisplay = produceData[season] ?? []
		self.season = season
		self.category = category
		self.searchString = searchString
		self.produceDataService = dataService
		self.numberOfRows = seasonProduceToDisplay?.count
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

		filterProduce(by: searchString)
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

	func filterProduce(by searchTextFieldString: String?) {
		guard let seasonData: [Produce] = produceData[season] else { return }
		searchString = searchTextFieldString ?? ""

		switch category {
		case .cancelled, .all:

			if searchString != "" {
				seasonProduceToDisplay = seasonData.filter {
					$0.produceName.lowercased().contains(searchString.lowercased())
				}
			} else {
				seasonProduceToDisplay = seasonData
			}
		case .fruit, .vegetables, .herbs:

			if searchString != "" {
				seasonProduceToDisplay = seasonData.filter {
					$0.category == category
					&& $0.produceName.lowercased().contains(searchString.lowercased())
				}
			} else {
				seasonProduceToDisplay = seasonData.filter { $0.category == category }
			}
		}
	}
}
