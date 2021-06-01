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

	// TODO: get the order of this the same everywhere.
    @IBOutlet weak var infoTextBlock: UILabel!

	var viewModel: InfoViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
		setUpNavigationController()
		self.definesPresentationContext = true
		self.providesPresentationContextTransitionStyle = true

		// If a location was detected, replace "Australia" with the state
		if viewModel.location != StateLocation.noState {
			let usersStateInAustralia = String(describing: viewModel.location).uppercased()
			infoTextBlock.text = Constants.infoPageSpiel.replacingOccurrences(of: Constants.straya, with: "\(usersStateInAustralia)")
		// else display "Australia" in default spiel
        } else {
            infoTextBlock.text = Constants.infoPageSpiel
        }
    }

	// MARK: Setup

	func setUpNavigationController() {
		self.navigationController?.navigationBar.isHidden = true
	}

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

	// Copy my email address to the clipboard (if no email client)
    private func copyEmailToClipboard() {
        UIPasteboard.general.string = "clint.thomas@me.com"
    }

    @IBAction func privacyPolicyButtonPressed(_ sender: Any) {
        guard let url = URL(string: "https://clomas.github.io/seasonal/") else { return }
        UIApplication.shared.open(url)
    }
}

extension InfoViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let mailError = error {
            // TODO: Show error alert
			print(mailError)
            controller.dismiss(animated: true)
            return
        }
        controller.dismiss(animated: true)
    }
}
