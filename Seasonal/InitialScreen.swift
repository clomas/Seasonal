	//
	//  InitialScreen.swift
	//  Seasonal
	//
	//  Created by Clint Thomas on 3/7/2025.
	//  Copyright © 2025 Clint Thomas. All rights reserved.
	//

import SwiftUI

struct InitialScreen: View {
	@EnvironmentObject var coordinator: AppCoordinator

	@State private var selectedTab = 0
	@State private var showErrorSheet = false

	@State private var showAlert: Bool = false

	var body: some View {
		VStack {
			ZStack {
				GlassIconBackground()
				Image("Logo")
					.resizable()
					.opacity(8)
			}
			.frame(width: 200, height: 200)

			switch coordinator.state {
			case .networkFailed:
				VStack {
					Text("Unable to connect to the internet")
						.padding(.bottom)
					Button("Try again") {

					}
				}
				.transition(.fallFromTop)
			case .locationNotFound:
				VStack {
					Text("Choose your location")
						.padding(.bottom)
					ForEach(StateLocation.allCases, id: \.self) { state in
						if state.fullName != StateLocation.noState.fullName {
							Button(state.fullName.capitalized) {

							}
							.padding(8)
						}
					}
					Button("Try find location again") {

					}
					.padding(50)
				}
			case .initial:
				ProgressView()
					.frame(width: 15, height: 15)
					.transition(.fallFromTop)
			default:
				EmptyView()
			}
			Spacer()
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(Color(.welcomeBackground))
		.animation(.easeInOut(duration: 1.2), value: coordinator.state)
	}
}

struct GlassIconBackground: View {
	var body: some View {
		RoundedRectangle(cornerRadius: 24, style: .continuous)
			.fill(.ultraThinMaterial)
			.background(
				RoundedRectangle(cornerRadius: 24)
					.fill(Color.white.opacity(0.05))
			)
			.overlay(
				RoundedRectangle(cornerRadius: 24)
					.strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
			)
			.shadow(color: Color.black.opacity(0.1), radius: 10, y: 4)
	}
}

extension AnyTransition {
	static var fallFromTop: AnyTransition {
		.asymmetric(
			insertion: .move(edge: .top).combined(with: .opacity),
			removal: .opacity
		)
	}
}

#Preview {
	lazy var coord: AppCoordinator = {
		let coord = AppCoordinator(window: UIWindow())
		coord.state = .locationNotFound
		return coord
	}()

	InitialScreen()
		.environmentObject(coord)
}

#if DEBUG
//extension AppCoordinator {
//	static func preview() -> AppCoordinator {
//		AppCoordinator(window: UIWindow())
//	}
//}
#endif
