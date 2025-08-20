//  SplashScreenViewController.swift
//  Seasonal
//
//  Created by Clint Thomas on 7/7/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//

import UIKit

class SplashScreenViewController: UIViewController, InitialViewDelegate {

	var viewModel: SplashScreenViewModel?

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var internetLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

		viewModel?.coordinator?.initialViewDelegate = self
        internetLabel.text = ""
		activityIndicator.startAnimating()
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(true, animated: animated)
	}

	func networkFailed() {
		presentAlert(title: "Network Error",
					 message: "Unable to connect to the internet",
					 alertStyle: .alert,
					 actionTitles: ["Ok"],
					 actionStyles: [.default ],
					 actions: []
		)
	}

	func dataIsReady() {}

	func locationNotFound() {
		presentLocationNotFoundAlert { [weak self] (state: StateLocation) in
			self?.viewModel?.userChoseLocation(state: state)
		}
	}
}
