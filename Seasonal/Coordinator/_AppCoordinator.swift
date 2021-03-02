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
		let initialViewCoordinator = _InitialViewCoordinator(navigationController: navigationController)
		childCoordinators.append(initialViewCoordinator)
		initialViewCoordinator.start()
		window.rootViewController = navigationController
		window.makeKeyAndVisible()
	}

	func childDidFinish(_ childCoordinator: _Coordinator) {
		if let index = childCoordinators.firstIndex(where: { coordinator -> Bool in
			return childCoordinator === coordinator
		}) {
			childCoordinators.remove(at: index)
		}
	}
}
