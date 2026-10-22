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
			ViewThatFits(in: .vertical) {
				LaunchStatusView(state: appCoordinator.state)
				ScrollView {
					LaunchStatusView(state: appCoordinator.state)
				}
			}
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
