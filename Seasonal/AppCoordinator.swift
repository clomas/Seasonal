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

@available(iOS 26, *)
enum AppCoordinatorState {
	case dataIsReady
	case networkFailed
	case locationNotFound
	case initial
	case dataFailed
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
	private let produceCache: ProduceCache = ProduceCache()

	@Published var state: AppCoordinatorState = .initial
	var produce: [Produce]?

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
			let swiftUIView = RootView()
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

	// MARK: Data

	func produceFavourites() -> [Produce] {
		produceCache.favourites(from: produce ?? [])
	}

	func produceByPeriod<Period: PeriodType>(period: Period) -> [Produce] {
		switch period {
		case let month as Months:
			produceCache.byMonth(month, from: produce ?? [])
		case let season as Seasons:
			produceCache.bySeason(season, from: produce ?? [])
		default:
			[]
		}
	}

	func updateLikedProduce(id: Int?, liked: Bool?) {
		guard let id, let liked, id > 0 else {
			return
		}
		Task {
			await ProduceServicesManager.updateLike(id: id, liked: liked)
		}
	}

	private func getDataFromCloudKit(for location: StateLocation) {
		Task {
			do {
				let result = try await ProduceServicesManager.getDataFromCloudKit(for: location)
				switch result {
				case .success(let produce):
					await MainActor.run { [weak self] in
						self?.produce = produce
						self?.state = .dataIsReady
					}
				case .failure(let failure):
					state = .dataFailed
				}
			} catch {
				state = .dataFailed
			}
		}
	}
}
