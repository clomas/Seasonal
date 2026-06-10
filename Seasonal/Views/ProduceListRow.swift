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
				ZStack {
					Text(produce.name ?? "")
                        .font(.title2)
						.multilineTextAlignment(.center)
						.frame(maxWidth: .infinity)
					HStack {
						Image(produce.imageName ?? "")
							.resizable()
							.scaledToFit()
							.frame(width: 60, height: 60)

						Spacer()

						Button(action: {
							appCoordinator.produceStore.toggleLiked(for: produce.id)
						}) {
							if produce.liked == true { GradientHeartView() } else { EmptyHeartView() }
						}
						.animation(.bouncy, value: produce.liked)
						.padding(.trailing, 16)
					}
				}
				MonthsInSeasonCapsuleView(months: produce.months ?? [])
			}
			.padding(.bottom, 4)
			.padding(.leading, 4)
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
