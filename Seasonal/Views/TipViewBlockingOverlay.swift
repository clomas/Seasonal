//
//  TipViewOverlay.swift
//  Seasonal
//
//  Created by Clint Thomas on 9/11/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI
import TipKit

@available(iOS 26, *)
struct TipViewBlockingOverlay: View {

	let tip: any Tip
	/// Called if the tip is closed early, so the scrim doesn't keep blocking the screen without it.
	let onDismiss: () -> Void

	private let scrimOpacity = 0.3
	private let tipMaxWidth: CGFloat = 350

	var body: some View {
		ZStack {
			Color.black.opacity(scrimOpacity)
				.ignoresSafeArea()
				.accessibilityHidden(true)

			TipView(tip)
				.frame(maxWidth: tipMaxWidth)
				.padding()
				.transition(.opacity.combined(with: .scale))
		}
		.accessibilityAddTraits(.isModal)
		.task {
			for await status in tip.statusUpdates {
				if case .invalidated = status {
					onDismiss()
					return
				}
			}
		}
	}
}
