//
//  AppCoordinator.swift
//  Seasonal
//
//  Created by Clint Thomas on 16/2/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.

import Foundation
import UIKit
import Network

protocol Coordinator: AnyObject {
	func start()
}

protocol InitialCoordinatorDelegate: AnyObject {
	func dataIsReady()
	func networkFailed()
	func locationNotFound()
}

final class AppCoordinator: LocationDelegate {

	let cloudKitDataService = CloudKitDataService()

	private let window: UIWindow
	private let navigationController = UINavigationController()

	private(set) var childCoordinators: [Coordinator] = []
	private var networkService = NetworkService.instance()
	private var locationManager: LocationManager! = LocationManager.sharedInstance
	private var currentLocation: StateLocation = .noState
	private var produceData: [Produce]?
	private var isFirstRun: Bool {
		UserDefaults.isFirstLaunch()
	}
	private var networkAvailable: Bool {
		networkService.currentStatus == .satisfied
	}

	weak var initialCoordinatorDelegate: InitialCoordinatorDelegate?

	init(window: UIWindow) {
		self.window = window

		#if DEBUG
		if CommandLine.arguments.contains("enable-testing") {
			// if testing UI disable animations.
			UIView.setAnimationsEnabled(false)
		}
		#endif
	}

	func start() {
		loadInitialViewCoordinator()
		locationManager.locationDelegate = self

		if !networkAvailable {
			networkService.startMonitoring()
		} else {
			locationManager.start()
		}

		window.rootViewController = navigationController
		window.makeKeyAndVisible()
	}

	// Called from location manager
	// also called from updateChosenLocation
	// fetch data when conditions are right
	func locationReady(location: StateLocation) {

		// If not determined, wait until it is
		if locationManager.authStatus != .notDetermined {
			let storedLocation = GlobalSettings.location
			if let wrappedLocation = StateLocation.init(rawValue: storedLocation.state) {
				currentLocation = wrappedLocation
			}

			print(location, currentLocation)
			// If not found && nothing is stored
			if location == .noState && currentLocation == .noState {
					// choose your own location
				self.initialCoordinatorDelegate?.locationNotFound()

			// If location is found - go on and get that data
			} else if location != .noState {
				currentLocation = location
				GlobalSettings.location = Location(state: location.rawValue)
				getDataFromCloudKit(for: currentLocation)
			// If location services is denied and nothing stored - prompt user for state
			} else if locationManager.authStatus == .denied && currentLocation == .noState {
				initialCoordinatorDelegate?.locationNotFound()
			// If current location is stored - proceed
			} else if currentLocation != .noState {
				getDataFromCloudKit(for: currentLocation)
			}
		}
	}

	func loadMainViewCoordinator() {
		let mainViewCoordinator = MainViewCoordinator(navigationController: navigationController,
													  cloudKitDataService: cloudKitDataService,
													  dataFetched: produceData,
													  location: currentLocation
		)
		childCoordinators.append(mainViewCoordinator)
		mainViewCoordinator.parentCoordinator = self
		mainViewCoordinator.start()
	}

	private func getDataFromCloudKit(for location: StateLocation) {
		getData(for: location, dataFetched: { [weak self] (produce: [Produce]) in
		    self?.produceData = produce

			DispatchQueue.main.async {
				self?.initialCoordinatorDelegate?.dataIsReady()
			}
		})
	}

	// Bubbled up from viewController
	// let the user chose a location once then store it
	func updateChosenLocationUserDefaults(to location: StateLocation) {
		if UserDefaults.standard.string(forKey: "Location") == nil {
			GlobalSettings.location = Location(state: location.rawValue)
			// UserDefaults.standard.set(location.rawValue, forKey: "Location")
		}
		currentLocation = location
		getDataFromCloudKit(for: location)
	}

	private func getData(for location: StateLocation, dataFetched: @escaping ([Produce]) -> Void) {
		cloudKitDataService.getData(for: location, dataFetched: { data in
			do {
				dataFetched(try data.get())
			} catch {
				fatalError() // well I can't do much from here.
				#warning("crashing here on no internet")
				// TODO:
			}
		})
	}

	private func loadInitialViewCoordinator() {
		let initialViewCoordinator = InitialViewCoordinator(navigationController: navigationController,
															 firstRun: isFirstRun
		)
		childCoordinators.append(initialViewCoordinator)
		initialViewCoordinator.parentCoordinator = self
		initialViewCoordinator.start()
	}

	func internetStatusDidChange(status: NWPath.Status) {

		switch status {
		case .satisfied:
			locationManager.start()
		default:
			initialCoordinatorDelegate?.networkFailed()
		}
	}

	func childDidFinish(_ childCoordinator: Coordinator) {
		if let index = childCoordinators.firstIndex(where: { coordinator -> Bool in
			return childCoordinator === coordinator
		}) {
			childCoordinators.remove(at: index)
		}
	}
}
