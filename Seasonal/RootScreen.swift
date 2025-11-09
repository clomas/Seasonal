//
//  RootScreen.swift
//  Seasonal
//
//  Created by Clint Thomas on 3/7/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

// TODO:
// Info screen
// Search screen
// CloudKit works? (old and new)
// Wire up like button
// Work on like button appearance
// Cache everything, test cache

@available(iOS 26, *)
struct RootScreen: View {
	@EnvironmentObject var coordinator: AppCoordinator

	var body: some View {
		Group {
			switch coordinator.state {
			case .dataIsReady:
				MainTabScreen()
			default:
				InitialScreen()
					.glassEffect()

			}
		}
		.animation(.easeInOut, value: coordinator.state == .dataIsReady)
		.transition(.opacity)
	}
}
