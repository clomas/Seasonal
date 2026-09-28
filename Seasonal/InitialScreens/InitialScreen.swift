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

	private let stateChangeAnimationDuration: TimeInterval = 1.2

	var body: some View {
		VStack {
			switch appCoordinator.state {
			case .initial:
				AppLogo()
				ProgressView()
					.controlSize(.large)
					.tint(.primary)
			case let .dataFailed(errorTitle, errorMessage):
				AppLogo()
				FailureMessageView(title: errorTitle, message: errorMessage, onRetry: appCoordinator.retryFetchData)
			case .networkFailed:
				AppLogo()
				FailureMessageView(
					title: Strings.Launch.networkErrorTitle,
					message: Strings.Launch.networkErrorMessage,
					onRetry: appCoordinator.retryFetchData
				)
			case .locationNotFound:
				AppLogo()
				LocationPickerView(onSelect: appCoordinator.chooseInitialLocation, onFindLocationAgain: appCoordinator.retryStart)
			case .dataIsReady:
				EmptyView()
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.padding(.bottom, .space8)
		.background(Colour.background)
		.animation(.easeInOut(duration: stateChangeAnimationDuration), value: appCoordinator.state)
	}
}

@available(iOS 26, *)
#Preview {
	InitialScreen()
		.environmentObject(previewCoordinator)
}
