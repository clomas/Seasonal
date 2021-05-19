//
//  MenuBarItems.swift
//  Seasonal
//
//  Created by Clint Thomas on 21/4/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import Foundation

enum _MenuBarModel: String {

	case categories
	case altLabel

	func imageName() -> String {
		switch self {
			case .categories: return "\(Constants.categories).png"
			case .altLabel: return "\(Constants.allCategories).png"
		}
	}

	enum Months: Int, CaseIterable {

		case favourites
		case calendar
		case currentMonth
		case seasons
		case all
		case fruit
		case vegetables
		case herbs
		case cancel

		func imageName(currentMonth: Month) -> String {
			switch self {
			case .favourites: return "\(Constants.favourites).png"
			case .calendar: return "\(Constants.months).png"
			case .currentMonth: return currentMonth.calendarImageName
			case .seasons: return "\(Constants.seasons).png"
			case .all: return "\(Constants.categories).png"
			case .fruit: return "\(Constants.fruit).png"
			case .vegetables: return "\(Constants.vegetables).png"
			case .herbs: return "\(Constants.herbs).png"
			case .cancel: return "\(Constants.cancel).png"
			}
		}
	}

	enum Seasons: Int, CaseIterable {

		case summer
		case autumn
		case winter
		case spring
		case all
		case fruit
		case vegetables
		case herbs
		case cancel

		func imageName() -> String {
			switch self {
			case .summer: return "\(Season.summer).png"
			case .autumn: return "\(Season.autumn).png"
			case .winter: return "\(Season.winter).png"
			case .spring: return "\(Season.spring).png"
			case .all: return "\(Constants.categories).png"
			case .fruit: return "\(Constants.fruit).png"
			case .vegetables: return "\(Constants.vegetables).png"
			case .herbs: return "\(Constants.herbs).png"
			case .cancel: return "\(Constants.cancel).png"
			}
		}
	}
}



