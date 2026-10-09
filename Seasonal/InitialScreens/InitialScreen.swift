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
		// Scrolls only when large Dynamic Type sizes push the content past the screen.
		ViewThatFits(in: .vertical) {
			LaunchStatusView()
			ScrollView {
				LaunchStatusView()
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.padding(.bottom, .space8)
		.background(Colour.background)
		.animation(.easeInOut(duration: stateChangeAnimationDuration), value: appCoordinator.state)
		.onChange(of: appCoordinator.state) {
			AccessibilityNotification.ScreenChanged().post()
		}
	}
}

@available(iOS 26, *)
#Preview {
	InitialScreen()
		.environment(previewCoordinator)
}
