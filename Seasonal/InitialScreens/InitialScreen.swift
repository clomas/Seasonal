//
//  InitialScreen.swift
//  Seasonal
//
//  Created by Clint Thomas on 3/7/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

@available(iOS 26, *)
struct InitialScreen: View {

	@Environment(AppCoordinator.self) private var appCoordinator

	private let stateChangeAnimationDuration: TimeInterval = 1.2

	var body: some View {
		ZStack {
			// Scrolls only when large Dynamic Type sizes push the content past the screen.
			ViewThatFits(in: .vertical) {
				LaunchStatusView(state: appCoordinator.state)
				ScrollView {
					LaunchStatusView(state: appCoordinator.state)
				}
			}
			// A new identity per state cross-fades it. The animation is on the transition only:
			// animating the state change itself also animates the new layout in from the top-left.
			.id(appCoordinator.state)
			.transition(.opacity.animation(.easeInOut(duration: stateChangeAnimationDuration)))
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.padding(.bottom, .initialScreenLogoPadding)
		.background(Colour.background)
		.onChange(of: appCoordinator.state) {
			AccessibilityNotification.ScreenChanged().post()
		}
	}
}

#if DEBUG
@available(iOS 26, *)
#Preview {
	InitialScreen()
		.environment(previewCoordinator)
}
#endif
