//
//  LikedHeartView.swift
//  Seasonal
//
//  Created by Clint Thomas on 12/7/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

/// One stable symbol whose fill animates, so `.symbolEffect(.bounce)` fires on every toggle.
@available(iOS 26, *)
struct LikedHeartView: View {

	let liked: Bool

	private let size: CGFloat = 40
	private let unlikedScale: CGFloat = 0.9
	private let likedGradientRadius: CGFloat = 65
	private let unlikedGradientRadius: CGFloat = 50

	var body: some View {
		Image.favouritesFilled
			.resizable()
			.aspectRatio(contentMode: .fit)
			.frame(width: size, height: size)
			.foregroundStyle(fill)
			.scaleEffect(liked ? 1 : unlikedScale)
			.symbolEffect(.bounce, value: liked)
			.animation(.bouncy, value: liked)
	}

	private var fill: RadialGradient {
		liked
			? RadialGradient(colors: [.red, .pink, .white], center: .topLeading, startRadius: 0, endRadius: likedGradientRadius)
			: RadialGradient(
				colors: [Colour.emptyHeartGradient1, Colour.emptyHeartGradient2],
				center: .topLeading,
				startRadius: 0,
				endRadius: unlikedGradientRadius
			)
	}
}

@available(iOS 26, *)
#Preview {
	HStack {
		LikedHeartView(liked: false)
		LikedHeartView(liked: true)
	}
	.background(.white)
}
