//
//  Extensions-UIViewController.swift
//  Seasonal
//
//  Created by Clint Thomas on 16/2/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import UIKit

typealias AlertActionCallback = (UIAlertAction) -> Void

extension UIViewController {

	// MARK: Instantiating ViewControllers from storyboard

	static func instantiate<T>() -> T? {
		let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: .main)
		if let controller: T = storyboard.instantiateViewController(identifier: "\(T.self)") as? T {
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
					  actions: [(UIAlertAction) -> Void]) {

		let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: alertStyle)

		for (index, indexTitle) in actionTitles.enumerated() {
			let actionHandler: ((UIAlertAction) -> Void)? = actions.isEmpty ? nil : actions[index]
			let action: UIAlertAction = UIAlertAction(title: indexTitle, style: actionStyles[index], handler: actionHandler)

			alertController.addAction(action)
		}

		present(alertController, animated: true)
	}

	func presentLocationNotFoundAlert(chosenState: @escaping ((StateLocation) -> Void)) {
		presentAlert(title: "Undetermined Location",
					 message: "Choose your location",
					 alertStyle: .actionSheet,
					 actionTitles: Constants.allLocationsForAlert,
					 actionStyles: [.default, .default, .default, .default, .default, .default, .default],

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

	func presentGenericAlert() {
		presentAlert(title: "Sorry",
					 message: "Something went wrong",
					 alertStyle: .alert,
					 actionTitles: [],
					 actionStyles: [.default],
					 actions: []
		)
	}

	func tapViewDismissesKeyboard() {
		let tapAwayFromKeyboard: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
		tapAwayFromKeyboard.cancelsTouchesInView = false
		view.addGestureRecognizer(tapAwayFromKeyboard)
	}

	@objc func dismissKeyboard() {

		if let nav: UINavigationController = self.navigationController {
			nav.view.endEditing(true)
		}
	}
}
