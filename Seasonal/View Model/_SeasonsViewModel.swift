//
//  _SeasonsViewModel.swift
//  Seasonal
//
//  Created by Clint Thomas on 23/2/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import Foundation

final class _SeasonsViewModel {

	var viewModel = [Season:[_ProduceModel]]()

	init(produceData: [Produce]) {
		self.viewModel = self.sortViewModel(produce: produceData)
	}

	func sortViewModel(produce: [Produce]) -> [Season:[_ProduceModel]] {
		var seasonsArray = [Season: [_ProduceModel]]()

		Season.asArray.forEach { season in
			var seasonsProduce = [_ProduceModel]()
			if season != Season.cancelled {
				produce.forEach({ item in
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

	func filter(by season: Season, matching searchString: String,of filter: ViewDisplayed.ProduceFilter) -> [_ProduceModel] {
		switch filter {
		case .cancelled, .all:
			if searchString == "" {
				return self.viewModel[season]!
			} else {
				return self.viewModel[season]!.filter({ $0.produceName?.lowercased().contains(searchString.lowercased()) ?? false})
			}
		case .fruit, .vegetables, .herbs:
			if searchString == "" {
				return self.viewModel[season]!.filter({ $0.category == filter })
			} else {
				return self.viewModel[season]!.filter({ $0.category == filter &&
															$0.produceName?.lowercased().contains(searchString.lowercased()) ?? false})
			}
		}
	}
}
