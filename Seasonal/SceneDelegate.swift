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

	let featureToggleHelper = FeatureToggleHelper()

	var window: UIWindow?

    var appCoordinatorVersionProtocol: AppCoordinatorVersionProtocol?

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let scene = (scene as? UIWindowScene) else { return }

		let window: UIWindow = UIWindow(windowScene: scene)
		self.window = window

		if featureToggleHelper.isEnabled(.useSwiftUI), #available(iOS 26, *) {
			appCoordinatorVersionProtocol = AppCoordinator(window: window)
            appCoordinatorVersionProtocol?.start()
		} else {
            appCoordinatorVersionProtocol = AppCoordinatorOld(window: window)
            appCoordinatorVersionProtocol?.start()
		}
	}
}
