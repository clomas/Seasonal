//
//  EmptyHeartView.swift
//  Seasonal
//
//  Created by Clint Thomas on 12/7/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

struct EmptyHeartView: View {
	var body: some View {
		Image.heartFill
			.resizable()
			.aspectRatio(contentMode: .fit)
			.frame(width: 40, height: 60)
			.foregroundStyle(
				RadialGradient(
					colors: [Colour.emptyHeartGradient1, Colour.emptyHeartGradient2],
					center: .topLeading,
					startRadius: 0,
					endRadius: 50
				)
			)
	}
}

#Preview {
	HStack {
		GradientHeartView()
		EmptyHeartView()
	}
}
