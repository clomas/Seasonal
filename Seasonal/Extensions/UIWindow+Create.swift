//
//  UIWindow+Create.swift
//  Seasonal
//
//  Created by Clint Thomas on 20/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import UIKit

extension UIWindow {
	static func create() -> UIWindow? {
		UIApplication.shared.connectedScenes
			.compactMap { $0 as? UIWindowScene }
			.first
			.map { UIWindow(windowScene: $0) }
	}
}
