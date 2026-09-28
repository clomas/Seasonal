//
//  AppCoordinator.swift
//  Seasonal
//
//  Created by Clint Thomas on 30/6/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import CoreLocation
import Network
import SwiftUI
import UIKit

@available(iOS 26, *)
@MainActor
final class AppCoordinator: ObservableObject, @preconcurrency AppCoordinatorVersionProtocol {

    let produceStore = ProduceStore()

    private let window: UIWindow?

    @Published var state: AppCoordinatorState = .initial

    private var currentLocation: StateLocation = .noState
    private var networkService: NetworkService?
    private var locationManager: LocationService?
    private var cloudTask: Task<Void, Never>?
    private var locationTask: Task<Void, Never>?

    private var savedLocation: StateLocation {
        StateLocation(rawValue: GlobalSettings.location.state) ?? .noState
    }

    init(window: UIWindow?) {
        self.window = window

#if DEBUG
        if CommandLine.arguments.contains("enable-testing") {
            UIView.setAnimationsEnabled(false)
        }
#endif
    }

    func start() {
        let rootScreen = RootScreen()
            .environmentObject(self)
            .environmentObject(produceStore)

        window?.rootViewController = UIHostingController(rootView: rootScreen)

#if DEBUG
        // Boots on the preview fixtures so UI tests don't depend on reaching CloudKit.
        if CommandLine.arguments.contains("use-mock-data") {
            produceStore.loadMockData(previewProduce)
            state = .dataIsReady
            window?.makeKeyAndVisible()
            return
        }
#endif

        networkService = NetworkService(delegate: self)
        window?.makeKeyAndVisible()
    }

    func retryStart() {
        state = .initial
        Task { await networkService?.retry() }
    }

    func retryFetchData() {
        state = .initial
        fetchProduce(for: currentLocation)
    }

    /// Stores the location only if none is saved yet; use `changeLocation(to:)` to replace it.
    func chooseInitialLocation(_ location: StateLocation) {
        if GlobalSettings.location.state.isEmpty {
            GlobalSettings.location = Location(state: location.rawValue)
        }
        currentLocation = location
        fetchProduce(for: location)
    }

    func changeLocation(to location: StateLocation) {
        guard location != currentLocation else { return }
        GlobalSettings.location = Location(state: location.rawValue)
        currentLocation = location
        produceStore.prepareForLocationChange()
        state = .initial
        fetchProduce(for: location)
    }

    private func fetchProduce(for location: StateLocation) {
        cloudTask?.cancel()
        cloudTask = Task { @MainActor in
            let result = await produceStore.fetchFromCloudKit(for: location)
            if Task.isCancelled { return }

            switch result {
            case .success:
                state = .dataIsReady
            case let .failure(ckError):
                state = .dataFailed(errorTitle: ckError.errorTitle, errorMessage: ckError.errorMessage)
            }
        }
    }
}

// MARK: - LocationDelegate

@available(iOS 26, *)
extension AppCoordinator: @preconcurrency LocationDelegate {

    func locationReady(location: CLLocation?) {
        locationTask?.cancel()
        locationTask = Task { @MainActor in
            let detectedState = await LocationInformationManager().parseLocation(location)
            if Task.isCancelled { return }

            if detectedState != .noState {
                currentLocation = detectedState
                GlobalSettings.location = Location(state: detectedState.rawValue)
                fetchProduce(for: detectedState)
            } else if savedLocation != .noState {
                currentLocation = savedLocation
                fetchProduce(for: savedLocation)
            } else {
                state = .locationNotFound
            }
        }
    }
}

// MARK: - NetworkObserverDelegate

@available(iOS 26, *)
extension AppCoordinator: NetworkObserverDelegate {

    func internetStatusDidChange(status: NWPath.Status) {
        guard status == .satisfied else {
            state = .networkFailed
            return
        }

        Task { await networkService?.stop() }

        if savedLocation != .noState {
            currentLocation = savedLocation
            fetchProduce(for: savedLocation)
        } else {
            locationManager = LocationService(delegate: self)
        }
    }
}
