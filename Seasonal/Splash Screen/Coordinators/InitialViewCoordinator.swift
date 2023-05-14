//
//  InitialViewCoordinator.swift
//  Seasonal
//
//  Created by Clint Thomas on 16/2/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import UIKit
import Network

final class InitialViewCoordinator: Coordinator, InitialCoordinatorDelegate {

	private let navigationController: UINavigationController

	var parentCoordinator: AppCoordinator?

	private(set) var childCoordinators: [Coordinator] = [] // No Children at this stage

	weak var initialViewDelegate: InitialViewDelegate?
	private var firstRun: Bool

	private lazy var welcomeViewController: WelcomeViewController? = {
		guard let welcomeViewController: WelcomeViewController = .instantiate() else { return nil }
		let welcomeViewModel: WelcomeViewModel = WelcomeViewModel()
		welcomeViewModel.coordinator = self
		welcomeViewController.viewModel = welcomeViewModel
		return welcomeViewController
	}()

	private lazy var splashScreenViewController: SplashScreenViewController? = {
		guard let splashScreenViewController: SplashScreenViewController = .instantiate() else { return nil }
		let initialViewModel: SplashScreenViewModel = SplashScreenViewModel()
		initialViewModel.coordinator = self
		splashScreenViewController.viewModel = initialViewModel
		return splashScreenViewController
	}()

	init(navigationController: UINavigationController, firstRun: Bool) {
		self.navigationController = navigationController
		self.firstRun = firstRun
	}

	func start() {
		if let initialViewController: UIViewController = firstRun == true ? welcomeViewController : splashScreenViewController {
			navigationController.setViewControllers([initialViewController], animated: false)
		}

		parentCoordinator?.initialCoordinatorDelegate = self
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
		DispatchQueue.main.asyncAfter(deadline: .now(), execute: { [weak self] in
			self?.initialViewDelegate?.locationNotFound()
		})
	}

	func readyToDismiss() {
		if navigationController.viewControllers.first is SplashScreenViewController {
			navigationController.viewControllers.removeFirst()
			parentCoordinator?.childDidFinish(self)
		} else if navigationController.viewControllers.first is WelcomeViewController {
			// Load main here after dismiss is tapped on WelcomeViewController
			parentCoordinator?.loadMainViewCoordinator()
			navigationController.viewControllers.removeFirst()
			parentCoordinator?.childDidFinish(self)
		}
	}

	func userChoseLocation(state: StateLocation) {
		parentCoordinator?.updateChosenLocationUserDefaults(to: state)
	}
}
