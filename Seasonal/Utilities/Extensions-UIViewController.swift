//
//  Extensions-UIViewController.swift
//  Seasonal
//
//  Created by Clint Thomas on 16/2/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import UIKit

extension UIViewController {

	// Instantiating ViewControllers
	static func instantiate<T>() -> T {
		let storyboard = UIStoryboard(name: "Main", bundle: .main)
		let controller = storyboard.instantiateViewController(identifier: "\(T.self)") as! T
		return controller
	}

	// Presenting Alerts
	public func presentAlert(title: String,
							 message: String,
							 alertStyle: UIAlertController.Style,
							 actionTitles: [String],
							 actionStyles: [UIAlertAction.Style],
							 actions: [((UIAlertAction) -> Void)]) {

		let alertController = UIAlertController(title: title, message: message, preferredStyle: alertStyle)
		for(index, indexTitle) in actionTitles.enumerated() {
			let action = UIAlertAction(title: indexTitle, style: actionStyles[index], handler: actions[index])
			alertController.addAction(action)
		}
		self.present(alertController, animated: true)
	}

}
