//
//  AppDelegate.swift
//  Seasonal
//
//  Created by Clint Thomas on 25/9/18.
//  Copyright © 2018 Clint Thomas. All rights reserved.
//

import TipKit
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		if #available(iOS 17.0, *) {
#if DEBUG
			if CommandLine.arguments.contains("reset-onboarding") {
				try? Tips.resetDatastore()
			}
#endif
			try? Tips.configure([
				.displayFrequency(.immediate),
				.datastoreLocation(.applicationDefault)
			])
		}
		return true
	}

	// MARK: - UISceneSession lifecycle

	func application(
		_ application: UIApplication,
		configurationForConnecting connectingSceneSession: UISceneSession,
		options: UIScene.ConnectionOptions
	) -> UISceneConfiguration {
		UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}
}
