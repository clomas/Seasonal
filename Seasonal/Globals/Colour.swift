//
//  Colour.swift
//  Seasonal
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

enum Colour {
	static let inSeason = Color("inSeason")
	static let accent = inSeason
	/// Foreground for content drawn on `accent`; adapts so it stays legible in light and dark.
	static let onAccent = Color("onAccent")
	static let background = Color("tableViewCell")
	static let capsuleFill = inSeason.opacity(0.18)
	static let capsuleStroke = inSeason.opacity(0.45)
	static let emptyHeartGradient1 = Color("emptyHeartGradient1")
	static let emptyHeartGradient2 = Color("emptyHeartGradient2")
}
