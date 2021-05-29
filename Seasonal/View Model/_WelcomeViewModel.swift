//
//  _WelcomeViewModel.swift
//  Seasonal
//
//  Created by Clint Thomas on 16/2/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import Foundation
import UIKit

final class _WelcomeViewModel {

	weak var coordinator: _InitialViewCoordinator?

	// TODO: Constants
	let welcomeLabel = "Welcome to Seasonal"
	var videoName = "lightwelcomevideo"

	func dismissTapped() {
		coordinator?.readyToDismiss()
	}

	func userChoseLocation(state: StateLocation) {
		coordinator?.userChoseLocation(state: state)
	}
}

