//
//  AppCoordinatorVersionProtocol.swift
//  Seasonal
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import UIKit

@MainActor
protocol AppCoordinatorVersionProtocol {
    init(window: UIWindow?)
    func start()
}
