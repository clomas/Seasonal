//
//  FavouriteHeartView.swift
//  Seasonal
//
//  Created by Clint Thomas on 12/7/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

/// One stable symbol whose fill animates, so `.symbolEffect(.bounce)` fires on every toggle.
@available(iOS 26, *)
struct FavouriteHeartView: View {

	let isFavourite: Bool

	private let emptyScale: CGFloat = 0.9
	private let filledGradientSpread: CGFloat = 1.1
	private let emptyGradientRadius: CGFloat = 50

	@ScaledMetric(relativeTo: .title2) private var size: CGFloat = 40

	var body: some View {
		Image.favouritesFilled
			.resizable()
			.aspectRatio(contentMode: .fit)
			.frame(width: size, height: size)
			.foregroundStyle(fill)
			.scaleEffect(isFavourite ? 1 : emptyScale)
			.symbolEffect(.bounce, value: isFavourite)
			.animation(.bouncy, value: isFavourite)
	}

	private var fill: RadialGradient {
		isFavourite
			? RadialGradient(colors: Colour.favouriteHeartGradient, center: .topLeading, startRadius: 0, endRadius: size * filledGradientSpread)
			: RadialGradient(
				colors: [Colour.emptyHeartGradient1, Colour.emptyHeartGradient2],
				center: .topLeading,
				startRadius: 0,
				endRadius: emptyGradientRadius
			)
	}
}

@available(iOS 26, *)
#Preview {
	HStack {
		FavouriteHeartView(isFavourite: false)
		FavouriteHeartView(isFavourite: true)
	}
	.background(.white)
}
