//
//  _WelcomeViewCoordinator.swift
//  Seasonal
//
//  Created by Clint Thomas on 20/2/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import Foundation

import UIKit
import Network

//TODO: Delete this ? 

final class _WelcomeViewCoordinator: _Coordinator {

	private(set) var childCoordinators: [_Coordinator] = []
	private let navigationController: UINavigationController
	var dataFetched: [Produce]?

	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
	}

	var networkService = NetworkService.sharedInstance()
	var locationManager: LocationManager! = LocationManager.sharedInstance

	func start() {
		loadInitialViewController()
	}

	func checkNetworkStatus() {
		if networkService.currentStatus != .satisfied {
			networkService.startMonitoring()
			print(networkService.currentStatus)
		} else {
			locationManager.start()
		}
	}

	// location ready callBack
//	func locationReady(location: State) {
//		getData(location: location, dataFetched: { produce in
//
//		})
//	}

	func loadInitialViewController() {
		// TODO: Generic here?
		if UserDefaults.isFirstLaunch() == true {
			// TODO: Rename WelcomeVC
			let initialViewController: _WelcomeViewController = .instantiate()
			let initialViewModel = _WelcomeViewModel()
			//initialViewModel.coordinator = self
			initialViewController.viewModel = initialViewModel
			navigationController.setViewControllers([initialViewController], animated: false)
		}
	}

	func internetStatusDidChange(status: NWPath.Status) {
		print("interent changed")
	}

	func childDidFinish(_ childCoordinator: _Coordinator) {
		if let index = childCoordinators.firstIndex(where: { coordinator -> Bool in
			return childCoordinator === coordinator
		}) {
			childCoordinators.remove(at: index)
		}
	}
}
