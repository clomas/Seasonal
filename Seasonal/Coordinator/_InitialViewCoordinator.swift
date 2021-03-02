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
	func viewReadyToDismiss()
}

final class _InitialViewCoordinator: _Coordinator, NetworkObserver, LocationDelegate {

	var parentCoordinator: _AppCoordinator?
	private(set) var childCoordinators: [_Coordinator] = []
	private let navigationController: UINavigationController
	var networkService = NetworkService.sharedInstance()
	var locationManager: LocationManager! = LocationManager.sharedInstance
	weak var initialViewDelegate: InitialViewDelegate?
	var produceData: [Produce]?

	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
	}
	
	func start() {
		locationManager.locationDelegate = self
		loadInitialViewController()
		if !networkAvailable() {
			networkService.startMonitoring()
			print(networkService.currentStatus)
		}
	}

	func networkAvailable() -> Bool {
		if networkService.currentStatus != .satisfied {
			return false
		} else {
			return true
		}
	}

	// location ready callBack
	func locationReady(location: StateLocation) {
		getData(location: location, dataFetched: { produce in
			DispatchQueue.main.async {
				self.initialViewDelegate?.viewReadyToDismiss()
				self.produceData = produce
			}
		})
	}

	func getData(location: StateLocation, dataFetched: @escaping([Produce]) -> (Void)) {
		// TODO: Move this to my service
		CloudKitDataHandler.instance.currentLocation = .newSouthWales
		CloudKitDataHandler.instance.getData(locationFound: location, dataFetched: { data in
			dataFetched(data)
		})
	}

	func initMainViewCoordinator() {
		if let produce = produceData {
			let mainViewCoordinator = _MainViewCoordinator(navigationController: navigationController, dataFetched: produce )
			childCoordinators.append(mainViewCoordinator)
			mainViewCoordinator.start()
		} else {
			fatalError("error fetching data")
		}
	}

	func loadInitialViewController() {
		// TODO: GEneric here?
//		if UserDefaults.isFirstLaunch() == true {
			let initialViewController: _WelcomeViewController = .instantiate()
			let initialViewModel = _WelcomeViewModel()
			initialViewModel.coordinator = self
			self.initialViewDelegate = initialViewController
			initialViewController.viewModel = initialViewModel
			navigationController.setViewControllers([initialViewController], animated: false)
//		} else {
//			// TODO: Rename InitialVC
//			let initialViewController = InitialVC()
//			let initialViewModel = _SplashScreenViewModel()
//			initialViewModel.coordinator = self
//			initialViewController.viewModel = initialViewModel
//			navigationController.setViewControllers([initialViewController], animated: false)
//		}
	}

	func internetStatusDidChange(status: NWPath.Status) {
		print("interent changed")
	}

	//    // MARK: Network Changed
	//    // If network changes, shouldn't run if OK initially
	//    func internetStatusDidChange(status: NWPath.Status) {
	//        if status == .satisfied {
	//            if statusViewModel == nil {
	//                initViewModel()
	//            }
	//            if firstRun == true && welcomeVC != nil {
	//                welcomeVC?.internetStatusDidChange(status: status)
	//                locationManager.start()
	//            }
	//        }
	//    }


	func didFinish() {
		parentCoordinator?.childDidFinish(self)
	}
}
