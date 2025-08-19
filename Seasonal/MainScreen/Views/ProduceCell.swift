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
			VStack(spacing: 6) {
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

						Button(action: {
//							produce.liked = !produce.liked
						}) {
							if produce.liked { GradientHeartView() } else { EmptyHeartView() }
						}
						.animation(.bouncy, value: produce.liked)
						.padding(.trailing, 16)
					}
				}
				MonthsInSeasonCapsuleView()
			}
			.padding(.bottom, 4)
			.padding(.leading, 4)
			.background(Colour.background)
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
