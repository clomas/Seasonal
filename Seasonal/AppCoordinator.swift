//
//  AppCoordinator.swift
//  Seasonal
//
//  Created by Clint Thomas on 30/6/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import CloudKit
import Network
import SwiftUI

@available(iOS 26, *)
@MainActor
@Observable
final class AppCoordinator: AppCoordinatorVersionProtocol {

    let produceStore = ProduceStore()

    @ObservationIgnored private let window: UIWindow?
    @ObservationIgnored private let locationService = LocationService()

    var state: AppCoordinatorState = .initial {
        didSet { isFindingLocation = false }
    }
    private(set) var isFindingLocation = false

    @ObservationIgnored private var currentLocation: StateLocation = .noState
    @ObservationIgnored private var networkTask: Task<Void, Never>?
    @ObservationIgnored private var locationTask: Task<Void, Never>?
    @ObservationIgnored private var cloudTask: Task<Void, Never>?
    @ObservationIgnored private var appearanceTask: Task<Void, Never>?

    private var savedLocation: StateLocation {
        StateLocation(rawValue: GlobalSettings.location.state) ?? .noState
    }

    init(window: UIWindow?) {
        self.window = window

#if DEBUG
        if CommandLine.arguments.contains("enable-testing") {
            UIView.setAnimationsEnabled(false)
            GlobalSettings.markSwipeTipShown()
        }
        if CommandLine.arguments.contains("reset-onboarding") {
            GlobalSettings.swipeTipShownVersion = ""
            GlobalSettings.selectedTab = .favourites
        }
#endif
    }

    func start() {
        let rootScreen = RootScreen()
            .environment(self)
            .environment(produceStore)

        window?.rootViewController = UIHostingController(rootView: rootScreen)
        followAppearanceSetting()
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

    /// Network is already up by the time the picker shows, so this skips straight to detection.
    func findLocationAgain() {
        isFindingLocation = true
        detectLocation()
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
        state = .initial
        fetchProduce(for: location)
    }

    /// The new location is only saved once its produce has loaded.
    func changeLocation(to location: StateLocation) async -> CKError? {
        guard location != currentLocation else { return nil }

        switch await produceStore.fetchFromCloudKit(for: location) {
        case .success:
            currentLocation = location
            GlobalSettings.location = Location(state: location.rawValue)
            return nil
        case let .failure(error):
            return error
        }
    }

    /// Set on the window rather than with `preferredColorScheme`, which doesn't restyle a sheet
    /// that's already open or reliably undo an override when switched back to automatic.
    private func followAppearanceSetting() {
        window?.overrideUserInterfaceStyle = ThemeStore.shared.appearance.userInterfaceStyle
        appearanceTask = Task {
            for await appearance in Observations({ ThemeStore.shared.appearance }) {
                window?.overrideUserInterfaceStyle = appearance.userInterfaceStyle
            }
        }
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
