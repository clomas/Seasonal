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

final class AppCoordinator: LocationDelegate, NetworkObserverDelegate {

	let cloudKitDataService: CloudKitDataService = CloudKitDataService()

	private let window: UIWindow
	private let navigationController: UINavigationController = UINavigationController()

	private(set) var childCoordinators: [Coordinator] = []
	private var networkService: NetworkService?
	private var currentLocation: StateLocation = .noState
	private var produceData: [ProduceModel]?
	private var isFirstRun: Bool {
		UserDefaults.isFirstLaunch()
	}

	lazy private var locationManager: LocationManager? = { LocationManager() }()

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
		networkService = NetworkService(delegate: self)

		window.rootViewController = navigationController
		window.makeKeyAndVisible()
	}

	// Called from location manager
	// also called from updateChosenLocation
	// fetch data when conditions are right
	func locationReady(location: StateLocation) {

		// If not determined, wait until it is
		if locationManager?.authStatus != .notDetermined {
			currentLocation = StateLocation(rawValue: GlobalSettings.location.state) ?? .noState

			// If not found && nothing is stored
			if location == .noState && currentLocation == .noState {
					// choose your own location
				initialCoordinatorDelegate?.locationNotFound()

			// If location is found - go on and get that data
			} else if location != .noState {
				currentLocation = location
				GlobalSettings.location = Location(state: location.rawValue)
				getDataFromCloudKit(for: currentLocation)

			// If location services is denied and nothing stored - prompt user for state
			} else if locationManager?.authStatus == .denied && currentLocation == .noState {
				initialCoordinatorDelegate?.locationNotFound()

			// If current location is stored - proceed
			} else if currentLocation != .noState {
				getDataFromCloudKit(for: currentLocation)
			}
		}
	}

	func loadMainViewCoordinator() {
		let mainViewCoordinator: MainViewCoordinator = MainViewCoordinator(navigationController: navigationController,
																		   cloudKitDataService: cloudKitDataService,
																		   dataFetched: produceData,
																		   location: currentLocation
		)
		childCoordinators.append(mainViewCoordinator)
		mainViewCoordinator.parentCoordinator = self
		mainViewCoordinator.start()
	}

	func internetStatusDidChange(status: NWPath.Status) {

		switch status {
		case .satisfied:
			instantiateLocationManager()
			networkService?.stop()
		default:
			initialCoordinatorDelegate?.networkFailed()
		}
	}

	func childDidFinish(_ childCoordinator: Coordinator) {
		if let index: Int = childCoordinators.firstIndex(where: { coordinator -> Bool in
			return childCoordinator === coordinator
		}) {
			childCoordinators.remove(at: index)
		}
	}

	private func getDataFromCloudKit(for location: StateLocation) {
		getData(for: location, dataFetched: { [weak self] (produce: [ProduceModel]) in
		    self?.produceData = produce

			DispatchQueue.main.asyncAfter(deadline: .now(), execute: { [weak self] in
				self?.initialCoordinatorDelegate?.dataIsReady()
			})
		})
	}

	// Bubbled up from viewController
	// let the user chose a location once then store it
	func updateChosenLocationUserDefaults(to location: StateLocation) {

		if GlobalSettings.location.state == "" {
			GlobalSettings.location = Location(state: location.rawValue)
		}
		currentLocation = location
		getDataFromCloudKit(for: location)
	}

	private func getData(for location: StateLocation, dataFetched: @escaping ([ProduceModel]) -> Void) {
		cloudKitDataService.getData(for: location, dataFetched: { [weak self] data in
			do {
				dataFetched(try data.get())
			} catch {
				self?.initialCoordinatorDelegate?.networkFailed()
			}
		})
	}

	private func loadInitialViewCoordinator() {
		let initialViewCoordinator: InitialViewCoordinator = InitialViewCoordinator(navigationController: navigationController,
																					firstRun: isFirstRun
		)
		childCoordinators.append(initialViewCoordinator)
		initialViewCoordinator.parentCoordinator = self
		initialViewCoordinator.start()
	}

	private func instantiateLocationManager() {
		locationManager = LocationManager()
		locationManager?.locationDelegate = self
	}
}
