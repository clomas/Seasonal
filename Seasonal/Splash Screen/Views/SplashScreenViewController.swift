//  SplashScreenViewController.swift
//  Seasonal
//
//  Created by Clint Thomas on 7/7/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//

import UIKit
import Network

class SplashScreenViewController: UIViewController, InitialViewDelegate {

	var viewModel: SplashScreenViewModel!

    @IBOutlet weak var activityMonitor: UIActivityIndicatorView!
    @IBOutlet weak var internetLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
		viewModel.coordinator?.initialViewDelegate = self
        internetLabel.text = ""
        activityMonitor.startAnimating()
    }

    private func goToiCloudSettings(alert: UIAlertAction!) {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (_) in
            })
        }
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(true, animated: animated)
	}

	func networkFailed() {
		presentAlert(title: "Network Error",
						  message: "Unable to connect to the internet",
						  alertStyle: .alert,
						  actionTitles: ["OK"],
						  actionStyles: [.default],
						  actions: []
		)
	}

	// not needed for this view
	func dataIsReady() {}

	func locationNotFound() {
		presentLocationNotFoundAlert { [weak self] (state: StateLocation) in
			self?.viewModel.userChoseLocation(state: state)
		}
	}
}
