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
    
    let showMonths: Bool

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
						.padding(.leading, .space3)
						.frame(width: 84, alignment: .leading)

					Text(produce.name ?? "")
						.font(.cardTitle)
						.multilineTextAlignment(.center)
						.frame(maxWidth: .infinity)

					Button(action: {
						withAnimation(.easeInOut(duration: 0.35)) {
							appCoordinator.produceStore.toggleLiked(for: produce.id)
						}
					}) {
						HeartView(liked: produce.liked == true)
					}
					.sensoryFeedback(trigger: produce.liked) { _, isLiked in
						isLiked ? .impact(flexibility: .solid) : .impact(flexibility: .soft)
					}
					.padding(.trailing, .space4)
					.frame(width: 84, alignment: .trailing)
					.accessibilityIdentifier("produceLikeButton_\(produce.id)")
				}
                if showMonths {
                    MonthsInSeasonCapsuleView(months: produce.months ?? [])
                }
			}
			.accessibilityIdentifier("produceRow_\(produce.id)")
			.padding(.bottom, .space1)
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
        ), showMonths: true
	)
	.environmentObject(previewCoordinator)
}
