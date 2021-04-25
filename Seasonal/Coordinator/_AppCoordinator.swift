//
//  _AppCoordinator.swift
//  Seasonal
//
//  Created by Clint Thomas on 16/2/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import Foundation
import UIKit

protocol _Coordinator: class {
	var childCoordinators: [_Coordinator] { get }
	func start()
	func childDidFinish(_ childCoordinator: _Coordinator)
}

extension _Coordinator {
	func childDidFinish(_ childCoordinator: _Coordinator) {}
}

class _AppCoordinator {
	private(set) var childCoordinators: [_Coordinator] = []
	private let window: UIWindow

	init(window: UIWindow) {
		self.window = window
	}

	func start() {
		// TODO: Try add nav controller later

		let navigationController = UINavigationController()
		let appEntryCoordinator = _AppEntryCoordinator(navigationController: navigationController)
		appEntryCoordinator.parentCoordinator = self
		childCoordinators.append(appEntryCoordinator)
		appEntryCoordinator.start()
		window.rootViewController = navigationController
		window.makeKeyAndVisible()
	}
}



// UP TO HERE
// move all the data fetching to here, then pass down decisions for dismissal

// then create a new coordinator which will be called _PrimaryCoordinator - which can have 2 coordinators but maybe that one is enough
// or just mainViewCoord will do?
