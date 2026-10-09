//
//  ThemeStore.swift
//  Seasonal
//
//  Created by Clint Thomas on 4/10/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Observation
import SwiftUI

@MainActor
@Observable
final class ThemeStore {
	static let shared = ThemeStore()

	var theme: Theme {
		didSet { GlobalSettings.theme = theme }
	}

	var appearance: Appearance {
		didSet { GlobalSettings.appearance = appearance }
	}

	var accent: Color { theme.accent }
	var onAccent: Color { theme.onAccent }
	var colorScheme: ColorScheme? { appearance.colorScheme }

	init() {
		theme = GlobalSettings.theme
		appearance = GlobalSettings.appearance
	}
}
