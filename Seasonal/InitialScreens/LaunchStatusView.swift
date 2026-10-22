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

	/// An input rather than read from the coordinator, so a copy fading out keeps showing its old state.
	let state: AppCoordinatorState
	private let logoSize: CGFloat = 150

	var body: some View {
		VStack {
			switch state {
			case .initial:
				logo
				ProgressView()
					.controlSize(.large)
					.tint(.primary)
					.accessibilityLabel(Strings.Launch.loading)
			case let .dataFailed(errorTitle, errorMessage):
				logo
				FailureMessageView(title: errorTitle, message: errorMessage, onRetry: appCoordinator.retryFetchData)
			case .networkFailed:
				logo
				FailureMessageView(
					title: Strings.Launch.networkErrorTitle,
					message: Strings.Launch.networkErrorMessage,
					onRetry: appCoordinator.retryStart
				)
			case .locationNotFound:
				logo
				LocationPickerView(
					isFindingLocation: appCoordinator.isFindingLocation,
					onSelect: appCoordinator.chooseInitialLocation,
					onFindLocationAgain: appCoordinator.findLocationAgain
				)
			case .dataIsReady:
				EmptyView()
			}
		}
	}

	private var logo: some View {
		Image(.logoGlass)
			.resizable()
			.frame(width: logoSize, height: logoSize)
			.padding()
			.accessibilityHidden(true)
	}
}
