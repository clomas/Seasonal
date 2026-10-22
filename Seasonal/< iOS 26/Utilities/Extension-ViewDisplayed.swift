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
		case .all: return ConstantsOld.all
		case .fruit: return ConstantsOld.fruit
		case .vegetables: return ConstantsOld.vegetables
		case .herbs: return ConstantsOld.herbs
		case .cancelled: return ConstantsOld.cancelled
		}
	}
}
