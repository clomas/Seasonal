//
//  LikedHeartView.swift
//  Seasonal
//
//  Created by Clint Thomas on 12/7/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

/// A single, stable `heart.fill` symbol whose fill + shadow animate between the
/// liked and unliked states. Keeping one symbol identity (rather than swapping
/// two views) is what lets `.symbolEffect(.bounce)` actually fire on each toggle.
@available(iOS 26, *)
struct HeartView: View {
	let liked: Bool

	private var fill: RadialGradient {
		liked
			? RadialGradient(colors: [.red, .pink, .white], center: .topLeading, startRadius: 0, endRadius: 65)
			: RadialGradient(colors: [Colour.emptyHeartGradient1, Colour.emptyHeartGradient2], center: .topLeading, startRadius: 0, endRadius: 50)
	}

	var body: some View {
		Image.heartFill
			.resizable()
			.aspectRatio(contentMode: .fit)
			.frame(width: 40, height: 40)
			.foregroundStyle(fill)
//			.shadow(color: .red.opacity(liked ? 0.1 : 0), radius: 6, x: -5, y: 0)
//			.shadow(color: .black.opacity(liked ? 0.1 : 0), radius: 5, x: 3, y: 10)
			.scaleEffect(liked ? 1.0 : 0.9)
			.symbolEffect(.bounce, value: liked)
			.animation(.bouncy, value: liked)
	}
}

@available(iOS 26, *)
#Preview {
	HStack {
		HeartView(liked: false)
		HeartView(liked: true)
	}
    .background(.white)
}
