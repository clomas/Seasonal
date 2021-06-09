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
	func networkFailed()
	func locationNotFound()
	func dataIsReady()
}

final class InitialViewCoordinator: Coordinator, InitialCoordinatorDelegate {

	var parentCoordinator: AppCoordinator?
	private(set) var childCoordinators: [Coordinator] = [] // No Children

	private let navigationController: UINavigationController

	weak var initialViewDelegate: InitialViewDelegate?

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
			loadWelcomeViewController()
		} else if firstRun == false {
			loadSplashScreenViewController()
		}
	}

	func loadWelcomeViewController() {
		let welcomeViewController: WelcomeViewController = .instantiate()
		let welcomeViewModel = WelcomeViewModel()
		welcomeViewModel.coordinator = self
		welcomeViewController.viewModel = welcomeViewModel
		navigationController.setViewControllers([welcomeViewController], animated: false)
	}

	func loadSplashScreenViewController() {
		let splashScreenViewController: SplashScreenViewController = .instantiate()
		let initialViewModel = SplashScreenViewModel()
		initialViewModel.coordinator = self
		splashScreenViewController.viewModel = initialViewModel
		navigationController.setViewControllers([splashScreenViewController], animated: false)
	}

	// Delegate methods to pass down to the viewControllers
	func dataIsReady() {
		// If first run, I need to present a dismiss button
		if firstRun == true {
			initialViewDelegate?.dataIsReady()
		// Else SplashScreen will just dismiss
		} else {
			parentCoordinator?.loadMainViewCoordinator()
			readyToDismiss()
		}
	}

	func networkFailed() {
		initialViewDelegate?.networkFailed()
	}

	func locationNotFound() {
		DispatchQueue.main.async {
			self.initialViewDelegate?.locationNotFound()
		}
	}

	func readyToDismiss() {
		if self.navigationController.viewControllers.first is SplashScreenViewController {
			self.navigationController.viewControllers.removeFirst()
			parentCoordinator?.childDidFinish(self)
		} else if self.navigationController.viewControllers.first is WelcomeViewController {
			// Load main here after dismiss is tapped on WelcomeViewController
			parentCoordinator?.loadMainViewCoordinator()
			self.navigationController.viewControllers.removeFirst()
			parentCoordinator?.childDidFinish(self)
		}
	}

	func userChoseLocation(state: StateLocation) {
		parentCoordinator?.updateChosenLocationUserDefaults(to: state)
	}
}
