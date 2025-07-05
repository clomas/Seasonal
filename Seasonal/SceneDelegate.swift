//
//  SceneDelegate.swift
//  Seasonal
//
//  Created by Clint Thomas on 16/2/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import Foundation
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?
	var appCoordinatorOld: AppCoordinatorOld?
	var appCoordinator: AppCoordinator?

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let scene = (scene as? UIWindowScene) else { return }

		let window: UIWindow = UIWindow(windowScene: scene)
		self.window = window

		if AppLaunchMode.useSwiftUI {
			appCoordinator = AppCoordinator(window: window)
			appCoordinator?.start()
		} else {
			appCoordinatorOld = AppCoordinatorOld(window: window)
			appCoordinatorOld?.start()
		}
	}
}
