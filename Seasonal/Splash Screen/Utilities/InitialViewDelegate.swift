//
//  InitialViewDelegate.swift
//  Seasonal
//
//  Created by Clint Thomas on 30/4/2023.
//  Copyright © 2023 Clint Thomas. All rights reserved.
//

import UIKit

protocol InitialViewDelegate: AnyObject {
	func networkFailed()
	func locationNotFound()
	func dataIsReady()
}

extension InitialViewDelegate where Self: UIViewController {

	func networkFailed() {
		presentAlert(title: "Network Error",
					 message: "Unable to connect to the internet",
					 alertStyle: .alert,
					 actionTitles: ["OK"],
					 actionStyles: [.default],
					 actions: []
		)
	}
}
