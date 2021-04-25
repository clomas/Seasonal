//
//  _SplashScreenViewModel.swift
//  Seasonal
//
//  Created by Clint Thomas on 16/2/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import Foundation

final class _SplashScreenViewModel {

	var coordinator: _InitialViewCoordinator?

	func dataIsReady() {
		// TODO:
	}


	func dismissTapped() {
		coordinator?.readyToDismiss()
	}
}

