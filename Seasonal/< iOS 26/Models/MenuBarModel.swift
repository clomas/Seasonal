//
//  MenuBarItems.swift
//  Seasonal
//
//  Created by Clint Thomas on 21/4/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import Foundation

struct MenuBarModel {

	enum CategoryLabel {
		case categories
		case altLabel

		func imageName() -> String {
			switch self {
			case .categories: return "\(ConstantsOld.categories).png"
			case .altLabel: return "\(ConstantsOld.allCategories).png"
			}
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

		func imageName(currentMonth: MonthOld) -> String {
			switch self {
			case .favourites: return "\(ConstantsOld.favourites).png"
			case .calendar: return "\(ConstantsOld.months).png"
			case .currentMonth: return currentMonth.calendarImageName
			case .seasons: return "\(ConstantsOld.seasons).png"
			case .all: return "\(ConstantsOld.categories).png"
			case .fruit: return "\(ConstantsOld.fruit).png"
			case .vegetables: return "\(ConstantsOld.vegetables).png"
			case .herbs: return "\(ConstantsOld.herbs).png"
			case .cancel: return "\(ConstantsOld.cancel).png"
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
			case .summer: return "\(Seasons.summer).png"
			case .autumn: return "\(Seasons.autumn).png"
			case .winter: return "\(Seasons.winter).png"
			case .spring: return "\(Seasons.spring).png"
			case .all: return "\(ConstantsOld.categories).png"
			case .fruit: return "\(ConstantsOld.fruit).png"
			case .vegetables: return "\(ConstantsOld.vegetables).png"
			case .herbs: return "\(ConstantsOld.herbs).png"
			case .cancel: return "\(ConstantsOld.cancel).png"
			}
		}
	}
}
