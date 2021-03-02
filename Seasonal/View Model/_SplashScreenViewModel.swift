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
	var dataReadyEvent = {}

	let welcomeLabel = "Welcome to Seasonal"
	var videoName = "lightwelcomevideo"

	//private let networkService: _NetworkServiceProtocol
	var networkCheck = _NetworkService.sharedInstance()

	init() {

	}

	func viewDidLoad() {
		// need this?
	}
}

