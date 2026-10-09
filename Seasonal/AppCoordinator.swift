//
//  AppCoordinator.swift
//  Seasonal
//
//  Created by Clint Thomas on 30/6/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import Network
import SwiftUI

@available(iOS 26, *)
@MainActor
@Observable
final class AppCoordinator: AppCoordinatorVersionProtocol {

    let produceStore = ProduceStore()

    @ObservationIgnored private let window: UIWindow?
    @ObservationIgnored private let locationService = LocationService()

    var state: AppCoordinatorState = .initial

    @ObservationIgnored private var currentLocation: StateLocation = .noState
    @ObservationIgnored private var networkTask: Task<Void, Never>?
    @ObservationIgnored private var locationTask: Task<Void, Never>?
    @ObservationIgnored private var cloudTask: Task<Void, Never>?

    private var savedLocation: StateLocation {
        StateLocation(rawValue: GlobalSettings.location.state) ?? .noState
    }

    init(window: UIWindow?) {
        self.window = window

#if DEBUG
        if CommandLine.arguments.contains("enable-testing") {
            UIView.setAnimationsEnabled(false)
            GlobalSettings.swipeTipShown = TipShown(swipe: true)
        }
        if CommandLine.arguments.contains("reset-onboarding") {
            GlobalSettings.swipeTipShown = TipShown(swipe: false)
        }
#endif
    }

    func start() {
        let rootScreen = RootScreen()
            .environment(self)
            .environment(produceStore)

        window?.rootViewController = UIHostingController(rootView: rootScreen)
        window?.makeKeyAndVisible()

#if DEBUG
        if CommandLine.arguments.contains("use-mock-data") {
            produceStore.loadMockData(previewProduce)
            state = .dataIsReady
            return
        }
#endif

        waitForNetwork()
    }

    func retryStart() {
        state = .initial
        waitForNetwork()
    }

    func retryFetchData() {
        state = .initial
        fetchProduce(for: currentLocation)
    }

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

    private func waitForNetwork() {
        networkTask?.cancel()
        networkTask = Task {
            for await path in NWPathMonitor() {
                guard path.status == .satisfied else {
                    state = .networkFailed
                    continue
                }
                networkIsAvailable()
                return
            }
        }
    }

    private func networkIsAvailable() {
        state = .initial
        if savedLocation != .noState {
            currentLocation = savedLocation
            fetchProduce(for: savedLocation)
        } else {
            detectLocation()
        }
    }

    private func detectLocation() {
        locationTask?.cancel()
        locationTask = Task {
            let location = await locationService.currentLocation()
            let detectedState = await LocationInformationManager().parseLocation(location)
            guard !Task.isCancelled else { return }

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

    private func fetchProduce(for location: StateLocation) {
        cloudTask?.cancel()
        cloudTask = Task {
            let result = await produceStore.fetchFromCloudKit(for: location)
            guard !Task.isCancelled else { return }

            switch result {
            case .success:
                state = .dataIsReady
            case let .failure(ckError):
                state = .dataFailed(errorTitle: ckError.errorTitle, errorMessage: ckError.errorMessage)
            }
        }
    }
}
