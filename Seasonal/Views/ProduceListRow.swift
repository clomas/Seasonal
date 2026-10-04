//
//  ProduceListRow.swift
//  Seasonal
//
//  Created by Clint Thomas on 6/7/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

@available(iOS 26, *)
struct ProduceListRow: View {

	let produce: Produce
	let showMonths: Bool
	var thisMonth: Months = .currentPeriod

	private let rowSpacing: CGFloat = 6
	private let imageSize: CGFloat = 60
	/// Equal leading and trailing slots keep the name centred however it wraps.
	private let sideSlotWidth: CGFloat = 84
	/// Twelve month letters share one row, so they can't grow indefinitely; VoiceOver reads the months in full.
	private let maxMonthsDynamicTypeSize: DynamicTypeSize = .accessibility1

	var body: some View {
		ZStack {
			Color(.systemBackground)
			VStack(spacing: rowSpacing) {
				HStack(spacing: 0) {
					Image(decorative: produce.imageName ?? "")
						.resizable()
						.scaledToFit()
						.frame(width: imageSize, height: imageSize)
						.padding(.leading, .space3)
						.frame(width: sideSlotWidth, alignment: .leading)

					Text(produce.name ?? "")
						.font(.cardTitle)
						.multilineTextAlignment(.center)
						.accessibilityAddTraits(.isHeader)
						.frame(maxWidth: .infinity)

					LikeButton(produce: produce)
						.padding(.trailing, .space4)
						.frame(width: sideSlotWidth, alignment: .trailing)
				}
				if showMonths {
					MonthsInSeasonCapsuleView(months: produce.months ?? [], thisMonth: thisMonth)
						.dynamicTypeSize(...maxMonthsDynamicTypeSize)
				}
			}
			.accessibilityElement(children: .contain)
			.accessibilityIdentifier("produceRow_\(produce.id)")
			.padding(.bottom, .space1)
			.background(Colour.background)
		}
	}
}

@available(iOS 26, *)
#Preview {
	ProduceListRow(produce: previewProduce[1], showMonths: true)
		.environmentObject(previewCoordinator.produceStore)
}
