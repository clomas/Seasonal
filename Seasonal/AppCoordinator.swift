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
    case dataFailed(errorTitle: String, errorMessage: String)
}

@available(iOS 26, *)
@MainActor
final class AppCoordinator: ObservableObject, @preconcurrency LocationDelegate, NetworkObserverDelegate, @preconcurrency AppCoordinatorVersionProtocol {
    
    let produceStore = ProduceStore()
    
    private let window: UIWindow?
    
    @Published var state: AppCoordinatorState = .initial
    
    private(set) var childCoordinators: [Coordinator] = []
    
    private var currentLocation: StateLocation = .noState
    private var isFirstRun: Bool {
        UserDefaults.isFirstLaunch()
    }
    
    private var networkService: NetworkService?
    private var locationManager: LocationService?
    private var cloudTask: Task<Void, Never>?
    private var locationTask: Task<Void, Never>?

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
    
    // MARK: Screen actions
    
    func start() {
        let rootScreen = RootScreen()
            .environmentObject(self)
            .environmentObject(produceStore)
            .environmentObject(featureToggleHelper)
        
        window?.rootViewController = UIHostingController(rootView: rootScreen)
        networkService = NetworkService(delegate: self)
        
        window?.makeKeyAndVisible()
    }
    
    func retryStart() {
        setState(.initial)
        
        Task {
            await networkService?.retry()
        }
    }
    
    func retryFetchData() {
        setState(.initial)
        
        getDataFromCloudKit(for: currentLocation)
    }
    
    func updateChosenLocationUserDefaults(to location: StateLocation) {
        if GlobalSettings.location.state == "" {
            GlobalSettings.location = Location(state: location.rawValue)
        }
        currentLocation = location
        getDataFromCloudKit(for: currentLocation)
    }

    /// Switches to a different state from within the app: persists the choice,
    /// clears the cached produce and re-fetches for the new location. Unlike
    /// `updateChosenLocationUserDefaults`, this always overwrites the stored state.
    func changeLocation(to location: StateLocation) {
        guard location != currentLocation else { return }
        GlobalSettings.location = Location(state: location.rawValue)
        currentLocation = location
        produceStore.prepareForLocationChange()
        setState(.initial)
        getDataFromCloudKit(for: location)
    }
    
    // MARK: Location delegate
    
    func locationReady(location: CLLocation?) {
        // Cancel any in-flight location resolution to ensure single-flight behaviour
        locationTask?.cancel()

        locationTask = Task { @MainActor in
            let detectedState = await LocationInformationManager().parseLocation(location)

            if Task.isCancelled { return }

            let savedState = StateLocation(rawValue: GlobalSettings.location.state) ?? .noState

            if detectedState != .noState {
                currentLocation = detectedState
                GlobalSettings.location = Location(state: detectedState.rawValue)
                getDataFromCloudKit(for: detectedState)
                return
            }

            if savedState != .noState {
                currentLocation = savedState
                getDataFromCloudKit(for: savedState)
                return
            }

            setState(.locationNotFound)
        }
    }
    
    // MARK: NetworkObserverDelegate
    
    func internetStatusDidChange(status: NWPath.Status) {
        switch status {
        case .satisfied:
            Task { await networkService?.stop() }

            let savedState = StateLocation(rawValue: GlobalSettings.location.state) ?? .noState
            if savedState != .noState {
                currentLocation = savedState
                getDataFromCloudKit(for: savedState)
            } else {
                locationManager = LocationService(delegate: self)
            }
        default:
            setState(.networkFailed)
        }
    }
    
    private func getDataFromCloudKit(for location: StateLocation) {
        // Cancel any in-flight request to ensure single-flight behaviour
        cloudTask?.cancel()

        cloudTask = Task { @MainActor in
            let result = await produceStore.fetchFromCloudKit(for: location)

            // If cancelled, do not update state
            if Task.isCancelled { return }

            switch result {
            case .success:
                setState(.dataIsReady)
            case let .failure(ckError):
                setState(.dataFailed(errorTitle: ckError.errorTitle, errorMessage: ckError.errorMessage))
            }
        }
    }

    // Cleanup function for single-flight CloudKit tasks
    func cancelCloudTasks() {
        cloudTask?.cancel()
        cloudTask = nil
    }
    
    private func setState(_ newState: AppCoordinatorState) {
        state = newState
    }
}
