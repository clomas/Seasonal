// TODO: Check for underscores urrwhere
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
        self.activityMonitor.startAnimating()
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
		self.presentAlert(title: "Network Error",
						  message: "Unable to connect to the internet",
						  alertStyle: .alert,
						  actionTitles: ["OK"],
						  actionStyles: [.default ],
						  actions: []
		)
	}

	// not needed for this view
	func dataIsReady() {}

	func locationNotFound() {
		self.presentAlert(title: "Undetermined Location",
					   message: "Choose your location",
					   alertStyle: .actionSheet,
					   actionTitles: [
						StateLocation.westernAustralia.fullName().capitalized,
						StateLocation.southAustralia.fullName().capitalized,
							StateLocation.northernTerritory.fullName().capitalized,
							StateLocation.queensland.fullName().capitalized,
							StateLocation.newSouthWales.fullName().capitalized,
							StateLocation.victoria.fullName().capitalized,
							StateLocation.tasmania.fullName().capitalized
					   ],
					   actionStyles: [.default, .default, .default, .default, .default, .default, .default],
					   actions: [ {_ in
								self.viewModel.userChoseLocation(state: .westernAustralia)
							}, {_ in
								self.viewModel.userChoseLocation(state: .southAustralia)
							}, {_ in
								self.viewModel.userChoseLocation(state: .northernTerritory)
							}, {_ in
								self.viewModel.userChoseLocation(state: .queensland)
							}, {_ in
								self.viewModel.userChoseLocation(state: .newSouthWales)
							}, {_ in
								self.viewModel.userChoseLocation(state: .victoria)
							}, {_ in
								self.viewModel.userChoseLocation(state: .tasmania)
							}
					   ]
		)
	}
}
