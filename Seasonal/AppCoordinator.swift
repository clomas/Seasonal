	//
	//  AppCoordinator.swift
	//  Seasonal
	//
	//  Created by Clint Thomas on 30/6/2025.
	//  Copyright © 2025 Clint Thomas. All rights reserved.
	//

import Foundation
import UIKit
import Network
import SwiftUI
import CoreLocation

enum AppLaunchMode {
	static var useSwiftUI: Bool {
		if #available(iOS 26, *) {
			true
		} else {
			false
		}
	}
}
@available(iOS 26, *)
enum AppCoordinatorState {
	case dataIsReady
	case networkFailed
	case locationNotFound
	case initial
}

protocol AppCoordinatorVersionProtocol {
    init(window: UIWindow?)
    func start()
}

@available(iOS 26, *)
@MainActor
final class AppCoordinator: ObservableObject, @preconcurrency LocationDelegate, NetworkObserverDelegate, @preconcurrency AppCoordinatorVersionProtocol {

	private let window: UIWindow?
	private let navigationController: UINavigationController = UINavigationController()

	@Published var state: AppCoordinatorState = .initial
	@Published var produceData: [Produce]?

	private(set) var childCoordinators: [Coordinator] = []

	private var currentLocation: StateLocation = .noState
	private var isFirstRun: Bool {
		UserDefaults.isFirstLaunch()
	}

	private var networkService: NetworkService?
	private var locationManager: LocationManager?

	init(window: UIWindow?) {
		self.window = window

#if DEBUG
		if CommandLine.arguments.contains("enable-testing") {
				// if testing UI disable animations.
			UIView.setAnimationsEnabled(false)
		}
#endif
	}

		// MARK: App initialisation

	func start() {
		if AppLaunchMode.useSwiftUI {
				// SwiftUI root
			let swiftUIView = RootView()
			window?.rootViewController = UIHostingController(rootView: swiftUIView.environmentObject(self))
		} else {
				// UIKit root
			let legacyRootVC = navigationController
			window?.rootViewController = UINavigationController(rootViewController: legacyRootVC)
		}

		networkService = NetworkService(delegate: self)

		window?.makeKeyAndVisible()
	}

	func tryDetectLocationAgain() {
		Task {
			await networkService?.retry()
		}
	}

		// Called from location manager
		// also called from updateChosenLocation
		// fetch data when conditions are right
	func locationReady(location: CLLocation?) {
		var stateLocation: StateLocation = .noState

		Task {
			stateLocation = await LocationInformationManager().parseLocation(location)
		}

			// If not determined, wait until it is
		if locationManager?.authStatus != .notDetermined {
			currentLocation = StateLocation(rawValue: GlobalSettings.location.state) ?? .noState

				// If not found && nothing is stored
			if stateLocation == .noState && currentLocation == .noState {
					// choose your own location
				state = .locationNotFound

					// If location is found - go on and get that data
			} else if stateLocation != .noState {
				currentLocation = stateLocation
				GlobalSettings.location = Location(state: stateLocation.rawValue)
				getDataFromCloudKit(for: currentLocation)

					// If location services is denied and nothing stored - prompt user for state
			} else if locationManager?.authStatus == .denied && currentLocation == .noState {
				state = .locationNotFound

					// If current location is stored - proceed
			} else if currentLocation != .noState {
				getDataFromCloudKit(for: currentLocation)
			}
		}
	}

	func updateLikedProduce(id: Int, liked: Bool) {
		Task {
			await ProduceServicesManager.updateLike(id: id, liked: liked)
		}
	}

	// Let the user chose a location once then store it
	func updateChosenLocationUserDefaults(to location: StateLocation) {

		if GlobalSettings.location.state == "" {
			GlobalSettings.location = Location(state: location.rawValue)
		}
		currentLocation = location
		getDataFromCloudKit(for: currentLocation)
	}

	func internetStatusDidChange(status: NWPath.Status) {

		switch status {
		case .satisfied:
			locationManager = LocationManager(delegate: self)
			Task { await networkService?.stop() }
		default:
			state = .networkFailed
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
		Task {
			let data = await ProduceServicesManager.getDataFromCloudKit(for: location)
			await MainActor.run {
				self.produceData = data
				self.state = .dataIsReady
			}
		}
	}
}

