//
//  InfoCardVC.swift
//  Seasonal
//
//  Created by Clint Thomas on 29/7/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//

import UIKit
import MessageUI

class InfoCardVC: UIViewController, Storyboarded {

    weak var coordinator: MainCoordinator?

    // This woul
    @IBOutlet weak var infoTextBlock: UILabel!
    @IBOutlet weak var emailButton: UIButton!
    var state: StateLocation!
    @IBOutlet weak var button: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        let stringForTextBlock = INFOPAGESPIEL

        if button == nil {
            print("NIL")
        }

        if state != StateLocation.noState {
            let usersStateInAustralia = String(describing: state).titleCase()
            infoTextBlock.text = stringForTextBlock.replacingOccurrences(of: STRAYA, with: "\(usersStateInAustralia)")
        } else {
            infoTextBlock.text = stringForTextBlock
        }
        
        self.definesPresentationContext = true
        self.providesPresentationContextTransitionStyle = true
    }

    @IBAction func downArrowPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func emailButtonPressed(_ sender: Any) {
        guard MFMailComposeViewController.canSendMail() else {
            self.presentAlert(title: "Unable to find mail app",
                                  message: "Copy 'clint.thomas@me.com' to clipboard?",
                                  alertStyle: .alert,
                                  actionTitles: ["Yes", "Nope"],
                                  actionStyles: [.default, .cancel],
                                  actions: [
                                      {_ in
                                           self.copyEmailToClipboard()
                                      },
                                      {_ in
                                           return
                                      }
                                 ])
            return
        }
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["clint.thomas@me.com"])
        composer.setSubject("")
        composer.setMessageBody("Hello!", isHTML: false)

        present(composer, animated: true)
    }

    private func copyEmailToClipboard() {
        UIPasteboard.general.string = "clint.thomas@me.com"
    }

    @IBAction func privacyPolicyButtonPressed(_ sender: Any) {
        guard let url = URL(string: "https://clomas.github.io/seasonal/") else { return }
        UIApplication.shared.open(url)
    }

}

extension InfoCardVC: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {

        if let _ = error {
            //Show error alert
            controller.dismiss(animated: true)
            return
        }
        controller.dismiss(animated: true)
    }
}

