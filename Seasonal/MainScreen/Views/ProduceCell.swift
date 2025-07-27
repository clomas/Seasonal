//
//  ProduceCell.swift
//  Seasonal
//
//  Created by Clint Thomas on 6/7/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

struct ProduceCell: View {
	var produce: ProduceModel

	var body: some View {
		ZStack {
			Color(.systemBackground)
			VStack(spacing: 12) {
				ZStack {
					Text(produce.name)
						.font(.headline)
						.multilineTextAlignment(.center)
						.frame(maxWidth: .infinity)
					HStack {
						Image(produce.imageName)
							.resizable()
							.scaledToFit()
							.frame(width: 60, height: 60)

						Spacer()

						Button(action: {}) {
							if produce.liked { GradientHeartView() } else { EmptyHeartView() }
						}
						.padding(.trailing, 16)
					}
				}
				MonthsInSeasonCapsuleView()
			}
			.background(Color(.systemBackground))
		}
	}
}
#Preview {
	ProduceCell(produce: .init(
		id: 1,
		name: "Bananas",
		category: .fruit,
		imageName: "Bananas", // make sure this image exists!
		description: "",
		months: [.august],
		seasons: [.spring],
		liked: true
	))
}
