//
//  Colour.swift
//  Seasonal
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

enum Colour {
	private static let capsuleFillOpacity = 0.18
	private static let capsuleStrokeOpacity = 0.45

	@MainActor static var inSeason: Color { ThemeStore.shared.accent }
	@MainActor static var accent: Color { inSeason }
	@MainActor static var onAccent: Color { ThemeStore.shared.onAccent }
	@MainActor static var capsuleFill: Color { inSeason.opacity(capsuleFillOpacity) }
	@MainActor static var capsuleStroke: Color { inSeason.opacity(capsuleStrokeOpacity) }

	static let background = Color(.tableViewCell)
	static let emptyHeartGradient1 = Color(.emptyHeartGradient1)
	static let emptyHeartGradient2 = Color(.emptyHeartGradient2)
	@available(iOS 26, *)
	static var favouriteHeartGradient: [Color] {
		[.pink.mix(with: .white, by: 0.3), .red, .red.mix(with: .black, by: 0.3)]
	}
}
