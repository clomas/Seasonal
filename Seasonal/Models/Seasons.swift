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

	var name: String {
		switch self {
		case .summer: return "summer"
		case .autumn: return "autumn"
		case .winter: return "winter"
		case .spring: return "spring"
		case .cancelled: return "cancelled"
		}
	}

	var image: Image {
		.cloudSun
	}
}
