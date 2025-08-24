//
//  ProduceListRow.swift
//  Seasonal
//
//  Created by Clint Thomas on 6/7/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

typealias ToggleLikeCallback = ((Produce) -> Void)?

struct ProduceListRow<Period: PeriodType>: View {

	// TODO: for testing
	let selectedPeriod: Period

	@Binding var produce: Produce
	var onToggleLike: ToggleLikeCallback

	var body: some View {
		ZStack {
			Color(.systemBackground)
			VStack(spacing: 6) {
				ZStack {
//					Text(produce.name ?? "")
					Text(selectedPeriod.name) // TODO: for testing
						.font(.headline)
						.multilineTextAlignment(.center)
						.frame(maxWidth: .infinity)
//						.lineLimit(2) // TODO: Remove this and the 2 lines below?
//						.minimumScaleFactor(0.8) // shrinks if needed
//						.fixedSize(horizontal: false, vertical: true)
					HStack {
						Image(produce.imageName ?? "")
							.resizable()
							.scaledToFit()
							.frame(width: 60, height: 60)

						Spacer()

						Button(action: {
							produce.liked?.toggle()
							onToggleLike?(produce)
						}) {
							if produce.liked == true { GradientHeartView() } else { EmptyHeartView() }
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
//	ProduceListRow(produce: .constant(.init(
//		id: 1,
//		name: "Bananas",
//		category: .fruit,
//		imageName: "Bananas",
//		description: "",
//		months: [.august],
//		seasons: [.spring],
//		liked: true
//	)), onToggleLike: { _ in })
}
