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
            .environmentObject(featureToggleHelper)
        
        window?.rootViewController = UIHostingController(rootView: rootScreen)
        networkService = NetworkService(delegate: self)
        
        window?.makeKeyAndVisible()
    }
    
    func retryStart() {
        state = .initial
        
        Task {
            await networkService?.retry()
        }
    }
    
    func retryFetchData() {
        state = .initial
        
        getDataFromCloudKit(for: currentLocation)
    }
    
    func updateChosenLocationUserDefaults(to location: StateLocation) {
        if GlobalSettings.location.state == "" {
            GlobalSettings.location = Location(state: location.rawValue)
        }
        currentLocation = location
        getDataFromCloudKit(for: currentLocation)
    }
    
    // MARK: Location delegate
    
    func locationReady(location: CLLocation?) {
        Task {
            let detectedState = await LocationInformationManager().parseLocation(location)
            
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
            
            state = .locationNotFound
        }
    }
    
    // MARK: NetworkObserverDelegate
    
    func internetStatusDidChange(status: NWPath.Status) {
        switch status {
        case .satisfied:
            locationManager = LocationService(delegate: self)
            Task { await networkService?.stop() }
        default:
            state = .networkFailed
        }
    }
    
    private func getDataFromCloudKit(for location: StateLocation) {
        Task {
            switch await produceStore.fetchFromCloudKit(for: location) {
            case .success:
                state = .dataIsReady
            case let .failure(ckError):
                state = .dataFailed(errorTitle: ckError.errorTitle, errorMessage: ckError.errorMessage)
            }
        }
    }
}
