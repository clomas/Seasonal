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

	var body: some View {
		if showTip {
			ZStack {
				// Overlay background that blocks taps
				Color.black.opacity(0.3)
					.ignoresSafeArea()
					.allowsHitTesting(true)

				TipView(tip)
					.frame(maxWidth: 350)
					.padding()
					.transition(.opacity.combined(with: .scale))
			}
		}
	}
}
