//
//  InfoViewController.swift
//  Seasonal
//
//  Created by Clint Thomas on 29/7/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//

import UIKit
import MessageUI

class InfoViewController: UIViewController {

	var viewModel: InfoViewModel?

    @IBOutlet weak var infoTextBlock: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

		self.definesPresentationContext = true
		self.providesPresentationContextTransitionStyle = true

		setUpNavigationController()

		// If a location was detected, replace "Australia" with the state
		if viewModel?.location != StateLocation.noState {
			let usersStateInAustralia = String(describing: viewModel?.location.fullName())
			infoTextBlock.text = Constants.infoPageSpiel.replacingOccurrences(of: Constants.straya, with: "\(usersStateInAustralia)")

		// else display "Australia" in default spiel
        } else {
            infoTextBlock.text = Constants.infoPageSpiel
        }
    }

	// MARK: Setup

	private func setUpNavigationController() {
		self.navigationController?.navigationBar.isHidden = true
	}

	// MARK: IBActions

    @IBAction func downArrowPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func emailButtonPressed(_ sender: Any) {
		// Else no mail client set up, copy email address to clipboard?
        guard MFMailComposeViewController.canSendMail() else {
            self.presentAlert(title: "Unable to find mail app",
                                  message: "Copy 'clint.thomas@me.com' to clipboard?",
                                  alertStyle: .alert,
                                  actionTitles: ["Yes", "Nope"],
                                  actionStyles: [.default, .cancel],
                                  actions: [ {_ in
                                           self.copyEmailToClipboard()
                                      }, {_ in
                                           return
                                      }
                                 ])
            return
        }

		// Compose an email form.
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["clint.thomas@me.com"])
        composer.setSubject("")
        composer.setMessageBody("Hello!", isHTML: false)
        present(composer, animated: true)
    }

	@IBAction func privacyPolicyButtonPressed(_ sender: Any) {
		guard let url = URL(string: "https://clomas.github.io/seasonal/") else { return }
		UIApplication.shared.open(url)
	}

	// Copy my email address to the clipboard (if no email client)
    private func copyEmailToClipboard() {
        UIPasteboard.general.string = "clint.thomas@me.com"
    }
}

extension InfoViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		if let mailError: Error = error {
			presentAlert(title: "Unable to compose mail",
						 message: mailError.localizedDescription,
						 alertStyle: .alert,
						 actionTitles: ["Ok"],
						 actionStyles: [.default],
						 actions: [ { _ in
						     controller.dismiss(animated: true)
						 }]
			)
        }
        controller.dismiss(animated: true)
    }
}
