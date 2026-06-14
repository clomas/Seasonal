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

	@EnvironmentObject var appCoordinator: AppCoordinator

	@Binding var produce: Produce

	var body: some View {
		ZStack {
			Color(.systemBackground)
			VStack(spacing: 6) {
				// Equal-width leading/trailing slots keep the name centred on the row while
				// letting it wrap in the middle as Dynamic Type grows — so it never overlaps
				// the image or heart the way a full-width ZStack overlay did.
				HStack(spacing: 0) {
					Image(produce.imageName ?? "")
						.resizable()
						.scaledToFit()
						.frame(width: 60, height: 60)
						.padding(.leading, 12)
						.frame(width: 84, alignment: .leading)

					Text(produce.name ?? "")
						.font(.title2)
						.multilineTextAlignment(.center)
						.frame(maxWidth: .infinity)

					Button(action: {
						appCoordinator.produceStore.toggleLiked(for: produce.id)
					}) {
						if produce.liked == true { GradientHeartView() } else { EmptyHeartView() }
					}
					.animation(.bouncy, value: produce.liked)
					.padding(.trailing, 16)
					.frame(width: 84, alignment: .trailing)
					.accessibilityIdentifier("produceLikeButton_\(produce.id)")
				}
                MonthsInSeasonCapsuleView(months: produce.months ?? [])
			}
			.accessibilityIdentifier("produceRow_\(produce.id)")
			.padding(.bottom, 4)
			.background(Colour.background)
		}
	}
}

@available(iOS 26, *)
#Preview {
	ProduceListRow(
		produce: .constant(
			.init(
				id: 122,
				name: "Bananas",
				category: .fruit,
				imageName: "Bananas",
				description: "",
				months: [.august, .september, .january, .december],
				seasons: [.spring],
				liked: true
			)
		)
	)
	.environmentObject(previewCoordinator)
}
