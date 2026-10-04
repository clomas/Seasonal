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

	@Binding var showTip: Bool

	let tip: any Tip

	private let scrimOpacity = 0.3
	private let tipMaxWidth: CGFloat = 350

	var body: some View {
		if showTip {
			ZStack {
				Color.black.opacity(scrimOpacity)
					.ignoresSafeArea()
					.allowsHitTesting(true)
					.accessibilityHidden(true)

				TipView(tip)
					.frame(maxWidth: tipMaxWidth)
					.padding()
					.transition(.opacity.combined(with: .scale))
			}
			.accessibilityAddTraits(.isModal)
		}
	}
}
