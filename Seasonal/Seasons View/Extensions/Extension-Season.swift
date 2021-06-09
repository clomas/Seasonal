//
//  Extension-Season.swift
//  Seasonal
//
//  Created by Clint Thomas on 29/4/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import Foundation

extension Season {

	var asString: String {
		switch self {
		case .summer: return "summer"
		case .autumn: return "autumn"
		case .winter: return "winter"
		case .spring: return "spring"
		case .cancelled: return "cancelled"
		}
	}
	var shortName: String {
		switch self {
		case .summer: return "sum"
		case .autumn: return "aut"
		case .winter: return "win"
		case .spring: return "spr"
		case .cancelled: return "can"
		}
	}

	static var asArray: [Season] {return self.allCases}
}
