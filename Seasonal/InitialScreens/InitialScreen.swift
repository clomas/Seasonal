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

	var body: some View {
		VStack {
			Image("Logo")
				.resizable()
				.frame(width: 150, height: 150)
				.padding()

			switch appCoordinator.state {
            case .initial:
                ProgressView()
                    .frame(width: 35, height: 35)
            case let .dataFailed(error):
                failureStackView(
                    title: "iCloud Error",
                    message: error.errorMessage
                ) {
                    appCoordinator.retryFetchData()
                }
			case .networkFailed:
                failureStackView(
                    title: "Network Error",
                    message: "Unable to connect to the internet"
                ) {
                    appCoordinator.retryFetchData()
                }
			case .locationNotFound:
				VStack(spacing: 10) {
					Text("Choose your location")
						.font(.title3.weight(.semibold))
						.padding(.bottom, 8)

					ForEach(StateLocation.allCases, id: \.self) { state in
						if state.fullName != StateLocation.noState.fullName {
							TintedGlassCapsuleButton(
								label: state.fullName.capitalized,
								systemImage: "mappin.and.ellipse"
							) {
								appCoordinator.updateChosenLocationUserDefaults(to: state)
							}
						}
					}
					Button {
						appCoordinator.retryStart()
					} label: {
						Label("Try find location again", systemImage: "location.magnifyingglass")
							.font(.subheadline)
							.foregroundStyle(.secondary)
					}
					.buttonStyle(.plain)
					.padding(.top, 24)
				}
				.padding(.horizontal, 24)
			default:
				EmptyView()
			}
			Spacer()
				.transition(.fallFromTop)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Colour.background)
		.animation(.easeInOut(duration: Constants.animationDuration), value: appCoordinator.state)
	}
    
    private func failureStackView(
        title: String,
        message: String,
        buttonImage: String = "arrow.clockwise",
        buttonLabel: String = "Try again",
        tapHandler: @escaping Closure,
    ) -> some View {
        VStack {
            Text(title)
                .multilineTextAlignment(.center)
            Text(message)
                .multilineTextAlignment(.center)
                .padding(.all)
            
            TintedGlassCapsuleButton(
                label: buttonLabel,
                systemImage: buttonImage,
                style: .prominent,
                tapHandler: tapHandler
            )
            .padding(.top, 16)
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
