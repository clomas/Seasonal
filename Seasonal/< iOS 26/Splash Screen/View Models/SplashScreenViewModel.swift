//
//  SplashScreenViewModel.swift
//  Seasonal
//
//  Created by Clint Thomas on 16/2/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import Foundation

final class SplashScreenViewModel {

	weak var coordinator: InitialViewCoordinator?

	@MainActor func userChoseLocation(state: StateLocation) {
		coordinator?.userChoseLocation(state: state)
	}
}
