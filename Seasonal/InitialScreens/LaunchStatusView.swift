//
//  LaunchStatusView.swift
//  Seasonal
//
//  Created by Clint Thomas on 4/10/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

@available(iOS 26, *)
struct LaunchStatusView: View {

	@Environment(AppCoordinator.self) private var appCoordinator

	var body: some View {
		VStack {
			switch appCoordinator.state {
			case .initial:
				AppLogo()
				ProgressView()
					.controlSize(.large)
					.tint(.primary)
					.accessibilityLabel(Strings.Launch.loading)
			case let .dataFailed(errorTitle, errorMessage):
				AppLogo()
				FailureMessageView(title: errorTitle, message: errorMessage, onRetry: appCoordinator.retryFetchData)
			case .networkFailed:
				AppLogo()
				FailureMessageView(
					title: Strings.Launch.networkErrorTitle,
					message: Strings.Launch.networkErrorMessage,
					onRetry: appCoordinator.retryStart
				)
			case .locationNotFound:
				AppLogo()
				LocationPickerView(onSelect: appCoordinator.chooseInitialLocation, onFindLocationAgain: appCoordinator.retryStart)
			case .dataIsReady:
				EmptyView()
			}
		}
	}
}
