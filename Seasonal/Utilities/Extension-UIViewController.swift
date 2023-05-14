//
//  Extensions-UIViewController.swift
//  Seasonal
//
//  Created by Clint Thomas on 16/2/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import UIKit

extension UIViewController {

	// MARK: Instantiating ViewControllers from storyboard

	static func instantiate<T>() -> T? {
		let storyboard = UIStoryboard(name: "Main", bundle: .main)
		if let controller = storyboard.instantiateViewController(identifier: "\(T.self)") as? T {
			return controller
		}
		return nil
	}

	// MARK: Present Alerts

	func presentAlert(title: String,
					  message: String,
					  alertStyle: UIAlertController.Style,
					  actionTitles: [String],
					  actionStyles: [UIAlertAction.Style],
					  actions: [((UIAlertAction) -> Void)]? = nil) {

		let alertController = UIAlertController(title: title, message: message, preferredStyle: alertStyle)

		for (index, indexTitle) in actionTitles.enumerated() {
			let action = UIAlertAction(title: indexTitle, style: actionStyles[index], handler: actions?[index])

			alertController.addAction(action)
		}

		self.present(alertController, animated: true)
	}

	func presentLocationNotFoundAlert(chosenState: @escaping ((StateLocation) -> Void)) {
		presentAlert(title: "Undetermined Location",
					 message: "Choose your location",
					 alertStyle: .actionSheet,
					 actionTitles: Constants.allLocationsForAlert,
					 actionStyles: [.default, .default, .default, .default, .default, .default, .default],
					 // formatting here is freaking out
					 actions: [ { _ in
									chosenState(.westernAustralia) }, { _ in
									chosenState(.southAustralia) }, { _ in
									chosenState(.northernTerritory) }, { _ in
									chosenState(.queensland) }, { _ in
									chosenState(.newSouthWales) }, { _ in
									chosenState(.victoria) }, { _ in
									chosenState(.tasmania) }
					 ]
		)
	}
}
