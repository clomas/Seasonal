//
//  AppDelegate.swift
//  Seasonal
//
//  Created by Clint Thomas on 25/9/18.
//  Copyright © 2018 Clint Thomas. All rights reserved.
//

import UIKit
import CoreData
import TipKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        if #available(iOS 17.0, *) {
            try? Tips.configure([
                .displayFrequency(.immediate),
                .datastoreLocation(.applicationDefault)
            ])
        }

        countLaunchForTabBarLabels()
		return true
	}

    /// Tracks launches and, once the threshold is reached, switches on the icon-only tab bar so
    /// returning users get a cleaner bar. Setting the toggle's UserDefault here (before the scene
    /// connects) means `FeatureToggleHelper` picks it up when it initialises.
    @MainActor
    private func countLaunchForTabBarLabels() {
        GlobalSettings.appLaunchCount += 1
        if GlobalSettings.appLaunchCount >= tabBarLabelHideLaunchCount {
            UserDefaults.standard.set(true, forKey: Feature.hideTabBarLabels.rawValue)
        }
    }

	// MARK: UISceneSession Lifecycle
	/// I've converted this Application to Scene Delegate model.

	func application(_ application: UIApplication,
					 configurationForConnecting connectingSceneSession: UISceneSession,
					 options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		// Called when a new scene session is being created.
		// Use this method to select a configuration to create the new scene with.
		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}

	func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
		// Called when the user discards a scene session.
		// If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
		// Use this method to release any resources that were specific to the discarded scenes, as they will not return.
	}
}
