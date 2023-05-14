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

		definesPresentationContext = true
		providesPresentationContextTransitionStyle = true

		setUpNavigationController()

		// If a location was detected, replace "Australia" with the state
		if viewModel?.location != .noState, let usersStateInAustralia: String = viewModel?.location.fullName() {
			infoTextBlock.text = Constants.infoPageSpiel.replacingOccurrences(of: Constants.straya, with: "\(usersStateInAustralia)")

		// else display "Australia" in default spiel
        } else {
            infoTextBlock.text = Constants.infoPageSpiel
        }
    }

	// MARK: IBActions

    @IBAction func downArrowWasTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func emailButtonWasTapped(_ sender: Any) {
		// Else no mail client set up, copy email address to clipboard?
        guard MFMailComposeViewController.canSendMail() else {

            return
        }

		// Compose an email form.
		let composer: MFMailComposeViewController = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["clint.thomas@me.com"])
        composer.setSubject("")
        composer.setMessageBody("Hello!", isHTML: false)
        present(composer, animated: true)
    }

	@IBAction func privacyPolicyButtonWasTapped(_ sender: Any) {
		guard let url = URL(string: "https://clomas.github.io/Seasonal/") else { return }
		UIApplication.shared.open(url)
	}

	// MARK: Setup

	private func setUpNavigationController() {
		navigationController?.navigationBar.isHidden = true
	}

	// Copy my email address to the clipboard (if no email client)
    private func presentCopyEmailToClipboardAlert() {
		presentAlert(title: "Unable to find mail app",
					 message: "Copy 'clint.thomas@me.com' to clipboard?",
					 alertStyle: .alert,
					 actionTitles: ["Yes", "Nope"],
					 actionStyles: [.default, .cancel],
					 actions: [ { _ in
						 UIPasteboard.general.string = "clint.thomas@me.com"
					 }, { _ in
						 // cancel
						 return
					 }]
		)
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
