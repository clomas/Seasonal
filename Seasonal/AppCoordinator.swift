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

enum AppCoordinatorState {
	case dataIsReady
	case networkFailed
	case locationNotFound
	case initial
}

@MainActor
final class AppCoordinator: ObservableObject, @MainActor LocationDelegate, NetworkObserverDelegate {

	let cloudKitDataService: CloudKitDataServiceOld = CloudKitDataServiceOld()

	private let window: UIWindow?
	private let navigationController: UINavigationController = UINavigationController()

	@Published var state: AppCoordinatorState = .initial
	@Published var produceData: [ProduceModel]?

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

		if #available(iOS 26.0, *) {
			Task {
				stateLocation = await LocationInformationManager().parseLocation(location)
			}
		} else {
				// TODO:

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

	// Let the user chose a location once then store it
	func updateChosenLocationUserDefaults(to location: StateLocation) {

		if GlobalSettings.location.state == "" {
			GlobalSettings.location = Location(state: location.rawValue)
		}
		currentLocation = location
		getDataFromCloudKit(for: location)
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
		getData(for: location, dataFetched: { [weak self] (produce: [ProduceModel]) in

			DispatchQueue.main.asyncAfter(deadline: .now(), execute: { [weak self] in
				self?.state = .dataIsReady
				self?.produceData = produce
			})
		})
	}

	private func getData(for location: StateLocation, dataFetched: @escaping ([ProduceModel]) -> Void) {
		cloudKitDataService.getData(for: location, dataFetched: { [weak self] data in
			do {
				dataFetched(try data.get())
			} catch {
				self?.state = .networkFailed
			}
		})
	}

	// MARK: Context update

//	func updateSearch(_ search: String) {
//		switch viewContext {
//		case .months(let month, let category, _):
//			viewContext = .months(month, category: category, search: search)
//		case .seasons(let season, let category, _):
//			viewContext = .seasons(season, category: category, search: search)
//		case .favourites(let category, _):
//			viewContext = .favourites(category: category, search: search)
//		}
//	}
//
//	func updateCategory(_ category: ViewDisplayed.ProduceCategory) {
//		switch viewContext {
//		case .months(let month, _, let search):
//			viewContext = .months(month, category: category, search: search)
//		case .seasons(let season, _, let search):
//			viewContext = .seasons(season, category: category, search: search)
//		case .favourites(_, let search):
//			viewContext = .favourites(category: category, search: search)
//		}
//	}
//
//	func updateMonth(_ month: Month) {
//		if case let .months(_, category, search) = viewContext {
//			viewContext = .months(month, category: category, search: search)
//		}
//	}
//
//	func updateSeason(_ season: Season) {
//		if case let .seasons(_, category, search) = viewContext {
//			viewContext = .seasons(season, category: category, search: search)
//		}
//	}
}
