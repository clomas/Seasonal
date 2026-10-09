//
//  RootScreen.swift
//  Seasonal
//
//  Created by Clint Thomas on 3/7/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

@available(iOS 26, *)
struct RootScreen: View {
	@Environment(AppCoordinator.self) private var coordinator

	var body: some View {
		Group {
			switch coordinator.state {
			case .dataIsReady:
				MainTabScreen()
			default:
				InitialScreen()
			}
		}
		.animation(.easeInOut, value: coordinator.state == .dataIsReady)
		.transition(.opacity)
		.preferredColorScheme(ThemeStore.shared.colorScheme)
	}
}
