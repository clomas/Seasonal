//
//  _AppCoordinator.swift
//  Seasonal
//
//  Created by Clint Thomas on 16/2/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import Foundation
import UIKit
import Network

protocol _Coordinator: AnyObject {
	var childCoordinators: [_Coordinator] { get }
	func start()
	func childDidFinish(_ childCoordinator: _Coordinator)
}

protocol InitialCoordinatorDelegate: AnyObject {
	func dataIsReady()
	func networkFailed()
	func locationNotFound()
}

extension _Coordinator {
	func childDidFinish(_ childCoordinator: _Coordinator) {}
}

final class _AppCoordinator: LocationDelegate {

	private(set) var childCoordinators: [_Coordinator] = []
	private let window: UIWindow

	weak var initialCoordinatorDelegate: InitialCoordinatorDelegate?
	private var networkService = NetworkService.sharedInstance()
	private var locationManager: LocationManager! = LocationManager.sharedInstance
	private var currentLocation: StateLocation = .noState
	private var produceData: [Produce]?

	private let navigationController = UINavigationController()

	init(window: UIWindow) {
		self.window = window
	}
	
	func start() {

//		let appEntryCoordinator = _AppEntryCoordinator(navigationController: navigationController)
//		appEntryCoordinator.parentCoordinator = self
//		childCoordinators.append(appEntryCoordinator)
//		appEntryCoordinator.start()

		loadInitialViewCoordinator()
		locationManager.locationDelegate = self
		if !networkAvailable {
			networkService.startMonitoring()
			print(networkService.currentStatus)
		}


		window.rootViewController = navigationController
		window.makeKeyAndVisible()
	}

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

	// location ready callBack
	func locationReady(location: StateLocation) {
		currentLocation = location
		getData(location: location, dataFetched: { produce in
			DispatchQueue.main.async {
				self.produceData = produce
				self.initialCoordinatorDelegate?.dataIsReady()
			}
		})
	}

	func getData(location: StateLocation, dataFetched: @escaping([Produce]) -> (Void)) {
		CloudKitDataService.instance.currentLocation = .newSouthWales
		CloudKitDataService.instance.getData(locationFound: location, dataFetched: { data in
			dataFetched(data)
		})
	}

	func loadInitialViewCoordinator() {
		let initialViewCoordinator = _InitialViewCoordinator(navigationController: navigationController,
															 firstRun: isFirstRun
		)
		childCoordinators.append(initialViewCoordinator)
		initialViewCoordinator.parentCoordinator = self
		initialViewCoordinator.start()
	}

	func dismissInitialViewController() {
		
	}

	func loadMainViewCoordinator() {
		if let produce = produceData {
			let mainViewCoordinator = _MainViewCoordinator(navigationController: navigationController, dataFetched: produce, location: currentLocation )
			childCoordinators.append(mainViewCoordinator)
			mainViewCoordinator.parentCoordinator = self
			mainViewCoordinator.start()
		} else {
			// TODO: Error handling here
			fatalError("error fetching data")
		}
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


