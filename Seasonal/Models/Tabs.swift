//
//  Tabs.swift
//  Seasonal
//
//  Created by Clint Thomas on 18/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import Foundation

enum Tabs: Hashable {
	case favourites(category: ViewDisplayed.ProduceCategory = .all, search: String)
	case months(Month, category: ViewDisplayed.ProduceCategory = .all, search: String)
	case seasons(Season, category: ViewDisplayed.ProduceCategory = .all, search: String)
		//		case categories(ViewDisplayed.ProduceCategory)
		//		case search(String = "")

	var title: String {
		switch self {
		case .favourites:
			"Favourites"
		case .months(let month, _, _):
			month.name
		case .seasons(let season, _, _):
			season.name
				//			case .categories(let category):
				//				return categoryTitle(category)
				//			case .search:
				//				return "Search"
		}
	}

	var currentSelectedMonth: Month {
		if case let .months(month, _, _) = self {
			return month
		}
		return .thisMonth // fallback for non-months cases
	}

	func updatingMonth(_ newMonth: Month) -> Tabs {
		switch self {
		case .months(_, let category, let search):
			.months(newMonth, category: category, search: search)
		case .favourites, .seasons:
			self
		}
	}

	func updatingCategory(_ newCategory: ViewDisplayed.ProduceCategory) -> Tabs {
		switch self {
		case .months(let month, _, let search):
			.months(month, category: newCategory, search: search)
		case .seasons(let season, _, let search):
			.seasons(season, category: newCategory, search: search)
		case .favourites(_, let search):
			.favourites(category: newCategory, search: search)
		}
	}

	func updatingSearch(_ newSearch: String) -> Tabs {
		switch self {
		case .months(let month, let category, _):
			.months(month, category: category, search: newSearch)
		case .seasons(let season, let category, _):
			.seasons(season, category: category, search: newSearch)
		case .favourites(let category, _):
			.favourites(category: category, search: newSearch)
		}
	}

	private func categoryTitle(_ category: ViewDisplayed.ProduceCategory) -> String {
		switch category {
		case .all: "All"
		case .fruit: "Fruit"
		case .vegetables: "Vegetables"
		case .herbs: "Herbs"
		case .cancelled: "Cancelled"
		}
	}
}
