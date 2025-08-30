//
//  LikedHeartView.swift
//  Seasonal
//
//  Created by Clint Thomas on 12/7/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

struct GradientHeartView: View {
	var body: some View {
		Image.heartFill
			.resizable()
			.aspectRatio(contentMode: .fit)
			.frame(width: 40, height: 40)
			.foregroundStyle(
				RadialGradient(
					colors: [.red, .pink, .white],
					center: .topLeading,
					startRadius: 0,
					endRadius: 65
				)
			)
			.shadow(color: .red.opacity(0.3), radius: 14, x: -5, y: 0)
			.shadow(color: .gray.opacity(0.3), radius: 14, x: 10, y: 10)
	}
}

#Preview {
	HStack {
		GradientHeartView()
		EmptyHeartView()
	}
}
