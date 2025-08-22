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
	@EnvironmentObject var appCoordinator: AppCoordinator

	@State private var selectedTab = 0
	@State private var showErrorSheet = false

	@State private var showAlert: Bool = false

	private var alertStrings: (title: String, message: String) {
		switch appCoordinator.state {
		case .networkFailed:
			(title: "Network Error", message: "Unable to connect to the internet")
		case .locationNotFound:
			(title: "Undetermined Location", message: "Choose your location")
		default:
			(title: "Sorry", message: "Something went wrong")
		}
	}

	var body: some View {
		VStack {
			ZStack {
//				GlassIconBackground()
                Image("Logo")
                    .resizable()
                    .glassEffect(.regular)
//						.opacity(8)
				
			}
			.frame(width: 150, height: 150)
			.padding()

			switch appCoordinator.state {
			case .networkFailed, .dataFailed:
				VStack {
					Text("Unable to connect to the internet")
						.padding(.all)
					GlassButton(label: "Try again") {

					}
				}
				.transition(.fallFromTop)
			case .locationNotFound:
				VStack {
                    Text("Choose your location")
                        .font(.title3)
                        .glassEffect(.regular)
                        .padding(.bottom)

					ForEach(StateLocation.allCases, id: \.self) { state in
						if state.fullName != StateLocation.noState.fullName {
							GlassButton(label: state.fullName.capitalized) {
								appCoordinator.updateChosenLocationUserDefaults(to:  state)
							}
							.padding(.horizontal, 20)
							.padding(.vertical, 8)
						}
					}
					// TODO: we want to do this?
					GlassButton(label: "Try find location again") {
//						coordinator.
					}
					.padding(50)
				}
			case .initial:
				ProgressView()
					.frame(width: 35, height: 35)
					.transition(.fallFromTop)
			default:
				EmptyView()
			}
			Spacer()
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(Color(.welcomeBackground))
		.animation(.easeInOut(duration: Constants.animationDuration), value: appCoordinator.state)
	}
}

struct GlassButton: View {

	let label: String
	let tapHandler: Closure

	var body: some View {
		if #available(iOS 26.0, *) {
			Button(action: {
				tapHandler()
			}) {
				Text(label)
					.font(.headline)
					.frame(maxWidth: .infinity)
			}
//			.background(.white.opacity(0.4))
//			.glassEffect(.regular.interactive())
			.clipShape(Capsule())
//			.shadow(radius: 4)
			.buttonStyle(GlassButtonStyle())
		}
	}
}
//struct GlassIconBackground: View {
//	var body: some View {
//		RoundedRectangle(cornerRadius: 24, style: .continuous)
//			.fill(.ultraThinMaterial)
//			.background(
//				RoundedRectangle(cornerRadius: 24)
//					.fill(Color.white.opacity(0.05))
//			)
//			.overlay(
//				RoundedRectangle(cornerRadius: 24)
//					.strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
//			)
//			.shadow(color: Color.black.opacity(0.1), radius: 10, y: 4)
//	}
//}

extension AnyTransition {
	static var fallFromTop: AnyTransition {
		.asymmetric(
			insertion: .move(edge: .top).combined(with: .opacity),
			removal: .opacity
		)
	}
}

@available(iOS 26, *)
#Preview {
	InitialScreen()
		.environmentObject(previewCoordinator)
}
