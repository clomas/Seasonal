//
//  InitialViewCoordinator.swift
//  Seasonal
//
//  Created by Clint Thomas on 16/2/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import UIKit
import Network

protocol InitialViewDelegate: class {
	func dataIsReady()
	func networkFailed()
	func locationNotFound()
}

final class _InitialViewCoordinator: _Coordinator, InitialCoordinatorDelegate {

	var parentCoordinator: _AppEntryCoordinator?
	private(set) var childCoordinators: [_Coordinator] = []
	var initialViewDelegate: InitialViewDelegate?

	var navigationController: UINavigationController
	var firstRun: Bool

	init(navigationController: UINavigationController, firstRun: Bool) {
		self.navigationController = navigationController
		self.firstRun = firstRun
	}
	
	func start() {
		loadInitialViewController()
		parentCoordinator?.initialCoordinatorDelegate = self
	}

	func loadInitialViewController() {
		print(UserDefaults.isFirstLaunch())
		if firstRun == true {
			let initialViewController: _WelcomeViewController = .instantiate()
			let initialViewModel = _WelcomeViewModel()
			initialViewModel.coordinator = self
			//self.initialViewDelegate = initialViewController
			initialViewController.viewModel = initialViewModel
			navigationController.setViewControllers([initialViewController], animated: false)
		} else if firstRun == false {
			let splashScreenViewController: _SplashScreenViewController = .instantiate()
			let initialViewModel = _SplashScreenViewModel()
			//self.initialViewDelegate = splashScreenViewController
			initialViewModel.coordinator = self
			splashScreenViewController.viewModel = initialViewModel
			navigationController.setViewControllers([splashScreenViewController], animated: false)
		}
	}

	// Delegate methods to pass down to the viewControllers
	func dataIsReady() {
		if firstRun == false {
			parentCoordinator?.loadMainViewCoordinator()
			readyToDismiss()
		}
	}

	func networkFailed() {
		initialViewDelegate?.networkFailed()
	}

	func locationNotFound() {
		initialViewDelegate?.locationNotFound()
	}

	func readyToDismiss() {
		parentCoordinator?.childDidFinish(self)
	}

	deinit {
		print("deinitialised yeh")
	}
}

