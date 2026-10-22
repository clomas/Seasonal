//
//  ProduceCategory.swift
//  Seasonal
//
//  Created by Clint Thomas on 19/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

enum ProduceCategory: String, CaseIterable, Codable {
	case fruit
	case vegetables = "veg"
	case herbs
	case all

	var title: String {
		switch self {
		case .fruit: Strings.Category.fruit
		case .vegetables: Strings.Category.vegetables
		case .herbs: Strings.Category.herbs
		case .all: Strings.Category.all
		}
	}

	var image: String {
		switch self {
		case .fruit: Symbol.fruit
		case .vegetables: Symbol.vegetables
		case .herbs: Symbol.herbs
		case .all: Symbol.category
		}
	}
}
