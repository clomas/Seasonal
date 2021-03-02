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

	var coordinator: _InitialViewCoordinator?

	let welcomeLabel = "Welcome to Seasonal"
	var videoName = "lightwelcomevideo"

	//private let networkService: _NetworkServiceProtocol
	//var networkCheck = _NetworkService.sharedInstance()


	init() {
		//initialViewDelegate = self
		// TODO:  control annimations from this viewmodel.
	}

	func viewDidLoad() {
		// need this?
	}

	func dismissTapped() {
		coordinator?.initMainViewCoordinator()
	}
}

