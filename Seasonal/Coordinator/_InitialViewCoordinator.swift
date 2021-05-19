//
//  InitialViewCoordinator.swift
//  Seasonal
//
//  Created by Clint Thomas on 16/2/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import UIKit
import Network

protocol InitialViewDelegate: AnyObject {
	func dataIsReady()
	func networkFailed()
	func locationNotFound()
}

final class _InitialViewCoordinator: _Coordinator, InitialCoordinatorDelegate {

	var parentCoordinator: _AppCoordinator?
	private(set) var childCoordinators: [_Coordinator] = []

	weak var initialViewDelegate: InitialViewDelegate?

	private let navigationController: UINavigationController
	private var firstRun: Bool

	init(navigationController: UINavigationController, firstRun: Bool) {
		self.navigationController = navigationController
		self.firstRun = firstRun
	}
	
	func start() {
		loadInitialViewController()
		parentCoordinator?.initialCoordinatorDelegate = self
	}

	func loadInitialViewController() {
		if firstRun == true {
			let initialViewController: _WelcomeViewController = .instantiate()
			let initialViewModel = _WelcomeViewModel()
			initialViewModel.coordinator = self
			initialViewController.viewModel = initialViewModel
			navigationController.setViewControllers([initialViewController], animated: false)
		} else if firstRun == false {
			let splashScreenViewController: _SplashScreenViewController = .instantiate()
			let initialViewModel = _SplashScreenViewModel()
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
		if navigationController.viewControllers.first is _SplashScreenViewController ||
			navigationController.viewControllers.first is _WelcomeViewController {
			navigationController.viewControllers.removeFirst()
		}
		parentCoordinator?.childDidFinish(self)
	}
}

