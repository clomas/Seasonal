//
//  ProduceCategory.swift
//  Seasonal
//
//  Created by Clint Thomas on 19/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

enum ProduceCategory: Int, CaseIterable {

	case fruit
	case vegetables
	case herbs
	case all

	var title: String {
		String(describing: self).capitalized
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
			.settings
		}
	}
}
