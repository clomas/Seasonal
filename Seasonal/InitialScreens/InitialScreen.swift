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
			Image("Logo")
				.resizable()
				.frame(width: 150, height: 150)
				.padding()

			switch appCoordinator.state {
			case .networkFailed, .dataFailed:
				VStack {
					Text("Unable to connect to the internet")
						.padding(.all)
					GlassButton(label: "Try again") {
						appCoordinator.retryStart()
					}
				}

			case .locationNotFound:
				VStack {
                    Text("Choose your location")
                        .font(.title3)
                        .padding(.bottom)

					ForEach(StateLocation.allCases, id: \.self) { state in
						if state.fullName != StateLocation.noState.fullName {
							GlassButton(label: state.fullName.capitalized) {
								appCoordinator.updateChosenLocationUserDefaults(to:  state)
							}
							.padding(.vertical, 8)
						}
					}
					GlassButton(label: "Try find location again") {
						appCoordinator.retryStart()
					}
					.padding(50)
				}
			case .initial:
				ProgressView()
					.frame(width: 35, height: 35)
			default:
				EmptyView()
			}
			Spacer()
				.transition(.fallFromTop)
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
			}
//			.frame(width: 300)
//			.glassEffect(.regular.interactive())
//			.clipShape(Capsule())
			.buttonStyle(GlassButtonStyle())
			.frame(minWidth: 300)

		}
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

@available(iOS 26, *)
#Preview {
	InitialScreen()
		.environmentObject(previewCoordinator)
}
