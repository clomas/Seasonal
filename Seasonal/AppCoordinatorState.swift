//
//  AppCoordinatorState.swift
//  Seasonal
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

@available(iOS 26, *)
enum AppCoordinatorState: Hashable {
    case initial
    case dataIsReady
    case networkFailed
    case locationNotFound
    case dataFailed(errorTitle: String, errorMessage: String)
}
