//
//  LikeButton.swift
//  Seasonal
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

@available(iOS 26, *)
struct LikeButton: View {

	@Environment(ProduceStore.self) private var produceStore

	let produce: Produce

	private let animationDuration: TimeInterval = 0.35

	var body: some View {
		Button(action: toggleLike) {
			LikedHeartView(liked: produce.liked)
				.frame(minWidth: .minimumTapTarget, minHeight: .minimumTapTarget)
				.contentShape(.rect)
		}
		.sensoryFeedback(trigger: produce.liked) { _, isLiked in
			isLiked ? .impact(flexibility: .solid) : .impact(flexibility: .soft)
		}
		.accessibilityLabel(Strings.Like.label)
		.accessibilityAddTraits(produce.liked ? .isSelected : [])
		.accessibilityIdentifier("produceLikeButton_\(produce.id)")
	}

	private func toggleLike() {
		withAnimation(.easeInOut(duration: animationDuration)) {
			_ = produceStore.toggleLiked(for: produce.id)
		}
	}
}

#if DEBUG
@available(iOS 26, *)
#Preview {
	LikeButton(produce: previewProduce[0])
		.environment(previewCoordinator.produceStore)
}
#endif
