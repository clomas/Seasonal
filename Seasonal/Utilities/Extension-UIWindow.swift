//
//  Extension-UIWindow.swift
//  Seasonal
//
//  Created by Clint Thomas on 17/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import UIKit

extension UIWindow {
	/// Creates a new UIWindow using the first available window scene
	/// - Parameter makeKey: Whether to make this window key and visible immediately
	/// - Returns: A new UIWindow instance, or nil if no window scene is available
	static func create(makeKey: Bool = false) -> UIWindow? {
		guard let windowScene = UIApplication.shared.connectedScenes
			.compactMap({ $0 as? UIWindowScene })
			.first else {
			return nil
		}

		let window = UIWindow(windowScene: windowScene)
		if makeKey {
			window.makeKeyAndVisible()
		}
		return window
	}
}
