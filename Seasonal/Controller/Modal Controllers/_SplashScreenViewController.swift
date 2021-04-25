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

	func networkFailed() {
		//
	}

	func locationNotFound() {
		//
	}

	func dataIsReady() {
		activityMonitor.stopAnimating()
	}

	var parentCoordinator: _InitialViewCoordinator?
	var viewModel: _SplashScreenViewModel!
    //var networkCheck = NetworkService.sharedInstance()

    @IBOutlet weak var activityMonitor: UIActivityIndicatorView!
    @IBOutlet weak var internetLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        internetLabel.text = ""
        self.activityMonitor.startAnimating()
		parentCoordinator?.initialViewDelegate = self
    }

//    func internetStatusDidChange(status: NWPath.Status) {
//        if status == .satisfied {
//            print("Interenet Connected")
//            DispatchQueue.main.async {
//                self.activityMonitor.isHidden = false
//                self.activityMonitor.startAnimating()
//                self.internetLabel.text = ""
//            }
//        } else if status == .unsatisfied {
//            DispatchQueue.main.async {
//                self.activityMonitor.isHidden = true
//                self.activityMonitor.stopAnimating()
//                self.internetLabel.text = "No Internet Connection!"
//            }
//        }
//    }

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
}
