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

    var logo: some View {
        Image("Logo")
            .resizable()
            .frame(width: 150, height: 150)
            .padding()
    }
    
	var body: some View {
		VStack {
			switch appCoordinator.state {
            case .initial:
                logo
                ProgressView()
                    .controlSize(.large)
                    .tint(.primary)

            case let .dataFailed(errorTitle, errorMessage):
                logo
                failureStackView(
                    title: errorTitle,
                    message: errorMessage
                ) {
                    appCoordinator.retryFetchData()
                }
			case .networkFailed:
                logo
                failureStackView(
                    title: "Network Error",
                    message: "Unable to connect to the internet"
                ) {
                    appCoordinator.retryFetchData()
                }
			case .locationNotFound:
                logo
				VStack(spacing: .space2) {
					Text("Choose your location")
						.font(.sectionTitle)
						.padding(.bottom, .space4)

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
							.font(.label)
							.foregroundStyle(Colour.accent)
					}
					.buttonStyle(.plain)
					.padding(.top, .space6)
				}
				.padding(.horizontal, .space6)
			default:
				EmptyView()
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, .space8)
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
                .font(.sectionTitle)
                .multilineTextAlignment(.center)
            Text(message)
                .font(.bodyText)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.all)

            TintedGlassCapsuleButton(
                label: buttonLabel,
                systemImage: buttonImage,
                style: .prominent,
                tapHandler: tapHandler
            )
            .padding(.top, .space4)
        }
    }
}

@available(iOS 26, *)
#Preview {
	InitialScreen()
		.environmentObject(previewCoordinator)
}
