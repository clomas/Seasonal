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
		Image(systemName: "heart.fill")
			.resizable()
			.aspectRatio(contentMode: .fit)
			.frame(width: 35, height: 40)
			.foregroundStyle(
				LinearGradient(
					colors: [.pink, .red],
					startPoint: .topLeading,
					endPoint: .bottomTrailing
				)
			)
			.shadow(color: .pink.opacity(0.4), radius: 10, x: 0, y: 5)
	}
}
