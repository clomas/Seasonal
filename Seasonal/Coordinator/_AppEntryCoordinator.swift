//
//  _AppEntryCoordinator.swift
//  Seasonal
//
//  Created by Clint Thomas on 19/4/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import UIKit
import Network

protocol InitialCoordinatorDelegate: class {
	func dataIsReady()
	func networkFailed()
	func locationNotFound()
}

final class _AppEntryCoordinator: _Coordinator, LocationDelegate {

	var parentCoordinator: _AppCoordinator?
	private(set) var childCoordinators: [_Coordinator] = []
	var initialCoordinatorDelegate: InitialCoordinatorDelegate?
	var navigationController: UINavigationController
	var networkService = NetworkService.sharedInstance()
	var locationManager: LocationManager! = LocationManager.sharedInstance
	var produceData: [Produce]?


	var isFirstRun: Bool {
		if UserDefaults.isFirstLaunch() == true {
			return true
		} else {
			return false
		}
	}

	var networkAvailable: Bool {
		if networkService.currentStatus != .satisfied {
			return false
		} else {
			return true
		}
	}

	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
	}

	func start() {
		loadInitialViewCoordinator()
		locationManager.locationDelegate = self
		if !networkAvailable {
			networkService.startMonitoring()
			print(networkService.currentStatus)
		}
	}

	// location ready callBack
	func locationReady(location: StateLocation) {
		getData(location: location, dataFetched: { produce in
			DispatchQueue.main.async {
				self.produceData = produce
				self.initialCoordinatorDelegate?.dataIsReady()
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

	func loadMainViewCoordinator() {
		if let produce = produceData {
			let mainViewCoordinator = _MainViewCoordinator(navigationController: navigationController, dataFetched: produce )
			childCoordinators.append(mainViewCoordinator)
			mainViewCoordinator.parentCoordinator = self
			mainViewCoordinator.start()
		} else {
			fatalError("error fetching data")
		}
	}

	func loadInitialViewCoordinator() {
		let initialViewCoordinator = _InitialViewCoordinator(navigationController: navigationController,
															 firstRun: isFirstRun
		)
		childCoordinators.append(initialViewCoordinator)
		initialViewCoordinator.parentCoordinator = self
		initialViewCoordinator.start()
	}

	func internetStatusDidChange(status: NWPath.Status) {

		if status == .unsatisfied {
			self.initialCoordinatorDelegate?.networkFailed()
		}
		// FOR TESTING
		//run and make sure this fires
		self.initialCoordinatorDelegate?.networkFailed()
		print("internet changed")
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

	func childDidFinish(_ childCoordinator: _Coordinator) {
		if let index = childCoordinators.firstIndex(where: { coordinator -> Bool in
			return childCoordinator === coordinator
		}) {
			childCoordinators.remove(at: index)
		}
	}
}
