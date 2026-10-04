//
//  Appearance.swift
//  Seasonal
//
//  Created by Clint Thomas on 4/10/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

enum Appearance: String, Codable, CaseIterable, Identifiable {
	case automatic, light, dark

	var id: String { rawValue }

	var title: String {
		switch self {
		case .automatic: Strings.Appearance.automatic
		case .light: Strings.Appearance.light
		case .dark: Strings.Appearance.dark
		}
	}

	/// `nil` follows the system setting.
	var colorScheme: ColorScheme? {
		switch self {
		case .automatic: nil
		case .light: .light
		case .dark: .dark
		}
	}
}
