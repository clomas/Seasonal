//
//  ProduceCategory.swift
//  Seasonal
//
//  Created by Clint Thomas on 19/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

enum ProduceCategory: String, CaseIterable, Codable {

	case fruit
	case vegetables = "veg"
	case herbs
	case all

    var menuTitle: String {
        if case .vegetables = self {
            String(describing: self).capitalized
        } else {
            buttonTitle
        }
    }

	var buttonTitle: String {
        self.rawValue.capitalized
	}

	var image: String {
		switch self {
		case .fruit:
			.fruit
		case .vegetables:
			.vegetables
		case .herbs:
			.herbs
		case .all:
			.category
		}
	}
}
