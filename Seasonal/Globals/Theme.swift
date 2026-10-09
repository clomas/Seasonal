//
//  Theme.swift
//  Seasonal
//
//  Created by Clint Thomas on 4/10/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

enum Theme: String, Codable, CaseIterable, Identifiable {
	case automatic, fresh, citrus, berry, ocean

	var id: String { rawValue }

	var title: String {
		switch self {
		case .automatic: Strings.Theme.automatic
		case .fresh: Strings.Theme.fresh
		case .citrus: Strings.Theme.citrus
		case .berry: Strings.Theme.berry
		case .ocean: Strings.Theme.ocean
		}
	}

	var accent: Color {
		switch resolved {
		case .fresh, .automatic: Color(.inSeason)
		case .citrus: Color(.citrusAccent)
		case .berry: Color(.berryAccent)
		case .ocean: Color(.oceanAccent)
		}
	}

	var onAccent: Color {
		switch resolved {
		case .fresh, .automatic: Color(.onAccent)
		case .citrus: Color(.onCitrusAccent)
		case .berry: Color(.onBerryAccent)
		case .ocean: Color(.onOceanAccent)
		}
	}

	init(season: Seasons) {
		switch season {
		case .spring: self = .fresh
		case .summer: self = .ocean
		case .autumn: self = .citrus
		case .winter: self = .berry
		}
	}

	private var resolved: Theme {
		self == .automatic ? Theme(season: Seasons.currentPeriod) : self
	}
}
