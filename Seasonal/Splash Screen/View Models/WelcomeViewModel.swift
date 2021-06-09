//
//  WelcomeViewModel.swift
//  Seasonal
//
//  Created by Clint Thomas on 16/2/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import Foundation

final class WelcomeViewModel {

	weak var coordinator: InitialViewCoordinator?

	let welcomeLabel = Constants.welcomeToSeasonal

	func dismissTapped() {
		coordinator?.readyToDismiss()
	}

	func userChoseLocation(state: StateLocation) {
		coordinator?.userChoseLocation(state: state)
	}
}
