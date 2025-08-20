//
//  Seasons.swift
//  Seasonal
//
//  Created by Clint Thomas on 18/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

enum Seasons: Int, PeriodType {

	case summer = 0
	case autumn = 1
	case winter = 2
	case spring = 3
	case cancelled = 4

	static let currentPeriod: Seasons = .autumn

	var image: Image {
		.seasons
	}

	// TODO: Can I decode this instead?
	var shortName: String {
		switch self {
		case .summer: return "sum"
		case .autumn: return "aut"
		case .winter: return "win"
		case .spring: return "spr"
		case .cancelled: return "can"
		}
	}
}
