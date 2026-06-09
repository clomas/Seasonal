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

protocol AppCoordinatorVersionProtocol {
    init(window: UIWindow?)
    func start()
}

@available(iOS 26, *)
enum AppCoordinatorState: Equatable {
	case dataIsReady
	case networkFailed
	case locationNotFound
	case initial
	case dataFailed(String)
    
    var alert: (title: String, message: String) {
        switch self {
        case .networkFailed:
            (title: "Network Error", message: "Unable to connect to the internet")
        case .locationNotFound:
            (title: "Undetermined Location", message: "Choose your location")
        case .dataFailed(let error):
            (title: "Error", message: error)
        default:
            (title: "Sorry", message: "Something went wrong")
        }
    }
}

@available(iOS 26, *)
@MainActor
final class AppCoordinator: ObservableObject, @preconcurrency LocationDelegate, NetworkObserverDelegate, @preconcurrency AppCoordinatorVersionProtocol {

	let produceStore = ProduceStore()

	private let window: UIWindow?
	private let navigationController: UINavigationController = UINavigationController()

	@Published var state: AppCoordinatorState = .initial

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

	let featureToggleHelper = FeatureToggleHelper()

	func start() {
			let swiftUIView = RootScreen()
				.environmentObject(self)
				.environmentObject(featureToggleHelper)
			window?.rootViewController = UIHostingController(rootView: swiftUIView)
		networkService = NetworkService(delegate: self)

		window?.makeKeyAndVisible()
	}

	func retryStart() {
		Task {
			await networkService?.retry()
		}
	}

	func locationReady(location: CLLocation?) {
		Task {
			let stateLocation = await LocationInformationManager().parseLocation(location)

			if locationManager?.authStatus != .notDetermined {
				currentLocation = StateLocation(rawValue: GlobalSettings.location.state) ?? .noState

				if stateLocation == .noState && currentLocation == .noState {
					state = .locationNotFound
				} else if stateLocation != .noState {
					currentLocation = stateLocation
					GlobalSettings.location = Location(state: stateLocation.rawValue)
					getDataFromCloudKit(for: currentLocation)
				} else if locationManager?.authStatus == .denied && currentLocation == .noState {
					state = .locationNotFound
				} else if currentLocation != .noState {
					getDataFromCloudKit(for: currentLocation)
				}
			}
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
			switch await produceStore.fetchFromCloudKit(for: location) {
			case .success:
				state = .dataIsReady
			case let .failure(error):
                state = .dataFailed(error.errorDescription)
			}
		}
	}
}
