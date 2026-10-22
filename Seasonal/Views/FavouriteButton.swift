//
//  FavouriteButton.swift
//  Seasonal
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

@available(iOS 26, *)
struct FavouriteButton: View {

	@Environment(ProduceStore.self) private var produceStore

	let produce: Produce

	private let animationDuration: TimeInterval = 0.35

	var body: some View {
		Button(action: toggleFavourite) {
			FavouriteHeartView(isFavourite: produce.isFavourite)
				.frame(minWidth: .minimumTapTarget, minHeight: .minimumTapTarget)
				.contentShape(.rect)
		}
		.sensoryFeedback(trigger: produce.isFavourite) { _, isFavourite in
			isFavourite ? .impact(flexibility: .solid) : .impact(flexibility: .soft)
		}
		.accessibilityLabel(Strings.Favourite.label)
		.accessibilityAddTraits(produce.isFavourite ? .isSelected : [])
		.accessibilityIdentifier("produceFavouriteButton_\(produce.id)")
	}

	private func toggleFavourite() {
		withAnimation(.easeInOut(duration: animationDuration)) {
			_ = produceStore.toggleFavourite(for: produce.id)
		}
	}
}

#if DEBUG
@available(iOS 26, *)
#Preview {
	FavouriteButton(produce: previewProduce[0])
		.environment(previewCoordinator.produceStore)
}
#endif
