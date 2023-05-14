//
//  WelcomeViewModel.swift
//  Seasonal
//
//  Created by Clint Thomas on 16/2/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import Foundation

final class WelcomeViewModel {

	let welcomeLabel: String = Constants.welcomeToSeasonal

	weak var coordinator: InitialViewCoordinator?

	func dismissWasTapped() {
		coordinator?.readyToDismiss()
	}

	func userChoseLocation(state: StateLocation) {
		coordinator?.userChoseLocation(state: state)
	}
}
