//
//  Coordinator.swift
//  Seasonal
//
//  Created by Clint Thomas on 19/8/20.
//  Copyright © 2020 Clint Thomas. All rights reserved.
//

import Foundation
import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: CustomNavigationController { get set }

    func start()
}
