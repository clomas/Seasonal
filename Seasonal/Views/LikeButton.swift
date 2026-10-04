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

	@EnvironmentObject var produceStore: ProduceStore

	let produce: Produce

	private let animationDuration: TimeInterval = 0.35

	var body: some View {
		Button {
			withAnimation(.easeInOut(duration: animationDuration)) {
				produceStore.toggleLiked(for: produce.id)
			}
		} label: {
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
}

@available(iOS 26, *)
#Preview {
	LikeButton(produce: previewProduce[0])
		.environmentObject(previewCoordinator.produceStore)
}
