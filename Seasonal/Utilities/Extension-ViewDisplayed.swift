//
//  Extension-ViewDisplayed.swift
//  Seasonal
//
//  Created by Clint Thomas on 29/4/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import Foundation

extension ViewDisplayed.ProduceCategory {

	static var asArray: [ViewDisplayed.ProduceCategory] {return self.allCases}

	var asString: String {
		switch self {
		case .all: return Constants.all
		case .fruit: return Constants.fruit
		case .vegetables: return Constants.vegetables
		case .herbs: return Constants.herbs
		case .cancelled: return Constants.cancelled
		}
	}
}
