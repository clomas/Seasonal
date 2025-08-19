//
//  ProduceCategory.swift
//  Seasonal
//
//  Created by Clint Thomas on 19/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

enum ProduceCategory: Int, CaseIterable {
	case all
	case fruit
	case vegetables
	case herbs

	var title: String {
		String(describing: self).capitalized
	}
}
