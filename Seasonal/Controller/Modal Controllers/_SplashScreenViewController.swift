//
//  _SplashScreenViewController.swift
//  Seasonal
//
//  Created by Clint Thomas on 7/7/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//

import UIKit
import Network

class _SplashScreenViewController: UIViewController, InitialViewDelegate {

	func dataIsReady() {
		activityMonitor.stopAnimating()
	}

	var coordinator: _InitialViewCoordinator?
	var viewModel: _SplashScreenViewModel!
    //var networkCheck = NetworkService.sharedInstance()

    @IBOutlet weak var activityMonitor: UIActivityIndicatorView!
    @IBOutlet weak var internetLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        internetLabel.text = ""
        self.activityMonitor.startAnimating()
		coordinator?.initialViewDelegate = self
    }

    private func goToiCloudSettings(alert: UIAlertAction!) {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
            })
        }
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(true, animated: animated)
	}
	
	func viewReadyToDismiss() {
		viewModel.dismissTapped()
	}

	func networkFailed() {
		self.presentAlert(title: "Network Error",
						  message: "Unable to connect to the internet",
						  alertStyle: .alert,
						  actionTitles: [],
						  actionStyles: [.default],
						  actions: []
		)
	}

	func locationNotFound() {
		if true {
			func networkFailed() {
				self.presentAlert(title: "Location Error",
								  message: "Unable to detect which state in Australia you live in, you will be shown general data for Australian Produce.",
								  alertStyle: .alert,
								  actionTitles: [],
								  actionStyles: [.default],
								  actions: []
				)
			}
		}
	}
}
