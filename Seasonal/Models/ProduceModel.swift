//
//  Produce.swift
//  Seasonal
//
//  Created by Clint Thomas on 21/11/20.
//  Copyright © 2020 Clint Thomas. All rights reserved.
//

import Foundation

struct Produce: Identifiable {

	var produce: ProduceModel

	var id: Int {
		produce.id
	}
	var produceName: String {
		produce.name
	}
	var imageName: String {
		produce.imageName
	}
	var category: ViewDisplayed.ProduceCategory? {
		produce.category
	}
	var months: [Months] {
		produce.months
	}
	var seasons: [SeasonsOld] {
		produce.seasons
	}
	var liked: Bool {
		get {
			return produce.liked
		} set(liked) {
			produce.liked = liked
		}
	}
}

struct ProduceModel: Identifiable {
    let id: Int
    let name: String
    let category: ViewDisplayed.ProduceCategory
    let imageName: String
    let description: String // Not implemented yet
    let months: [Months]
    let seasons: [SeasonsOld]
    var liked: Bool
}

extension ProduceModel {
	var produceId: Int {
		return id
	}
}

extension Array where Element == ProduceModel {

	/// Filters produce by period, category, and search. Works for any PeriodType.
	func filtered<Period: PeriodType>(
		by period: Period,
		category: ViewDisplayed.ProduceCategory,
		search: String
	) -> [ProduceModel] {
		self
			.filter { period.allCases.contains(period) && (category == .all || $0.category == category) }
			.filter { search.isEmpty || $0.name.localizedCaseInsensitiveContains(search) }
	}

	func filtered(by selectedTab: Tabs) -> [ProduceModel] {
		switch selectedTab {
		case .favourites(let category, let search):
			self
				.filter { $0.liked && (category == .all || $0.category == category) }
				.filter { search.isEmpty || $0.name.localizedCaseInsensitiveContains(search) }

		case .months(let month, let category, let search):
			self
				.filter { $0.months.contains(month) && (category == .all || $0.category == category) }
				.filter { search.isEmpty || $0.name.localizedCaseInsensitiveContains(search) }

		case .seasons(let season, let category, let search):
			self
				.filter { $0.seasons.contains(season) && (category == .all || $0.category == category) }
				.filter { search.isEmpty || $0.name.localizedCaseInsensitiveContains(search) }

//		case .categories(let category):
//			return produce.filter { category == .all || $0.category == category }

//		case .search(let term):
//			return produce.filter { $0.name.localizedCaseInsensitiveContains(term) }
		}
	}
}
