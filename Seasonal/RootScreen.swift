//
//  RootScreen.swift
//  Seasonal
//
//  Created by Clint Thomas on 3/7/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

// TODO: List
// Info screen
// Search screen
// CloudKit work (old and new)
// 

@available(iOS 26, *)
struct RootView: View {
	@EnvironmentObject var coordinator: AppCoordinator

	var body: some View {
		Group {
			switch coordinator.state {
			case .dataIsReady:
				MainTabScreen()
				
			default:
				if #available(iOS 26.0, *) {
					InitialScreen()
						.glassEffect()
				} 
			}
		}
		.animation(.easeInOut, value: coordinator.state == .dataIsReady)
		.transition(.opacity)
	}
}
