//
//  WelcomeViewController.swift
//  Seasonal
//
//  Created by Clint Thomas on 11/1/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//

import UIKit
import AVFoundation

class WelcomeViewController: UIViewController, InitialViewDelegate {

	var viewModel: WelcomeViewModel!

    @IBOutlet weak var activityMonitor: UIActivityIndicatorView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var dismissArrowButton: UIButton!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var AVPlayerView: AVPlayerView!

    private var player: AVPlayer!

	var videoName: String {
		if traitCollection.userInterfaceStyle == .dark {
			return Constants.darkWelcomeVideo
		} else {
			return Constants.lightWelcomeVideo
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		viewModel.coordinator?.initialViewDelegate = self
        setupViews()
    }

    private func setupViews() {
		welcomeLabel.text = viewModel.welcomeLabel
		activityMonitor.startAnimating()
		activityMonitor.hidesWhenStopped = true
		dismissButton.isHidden = true
		dismissArrowButton.isHidden = true
		dismissButton.isEnabled = false
		dismissArrowButton.isEnabled = false

		playVideo()
		animateWelcomeLabel()
    }

    // MARK: Video

    private func playVideo() {
        guard let path = Bundle.main.path(forResource: videoName, ofType: "mp4") else {
            return
        }
        player = AVPlayer(url: URL(fileURLWithPath: path))

        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: .mixWithOthers)
             try AVAudioSession.sharedInstance().setActive(true)
        } catch {
             print(error)
        }

		if let castedLayer = AVPlayerView.layer as? AVPlayerLayer {
        castedLayer.player = player
        castedLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        player.play()
        NotificationCenter.default.addObserver(self,
											   selector: #selector(playerItemDidReachEnd(notification:)),
											   name: .AVPlayerItemDidPlayToEndTime,
											   object: player.currentItem)
		}
    }

    // Start video over after completion
    @objc func playerItemDidReachEnd(notification: Notification) {
        if let playerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: CMTime.zero, completionHandler: nil)
			playVideo()
        }
    }

    // MARK: Animations

	// TODO: nothing happens here
	private func animateWelcomeLabel() {
		if self.dismissButton.isHidden == false {
			self.activityMonitor.isHidden = true
		}
		self.welcomeLabel.animatedWelcomeLabel(initialLabelText: viewModel.welcomeLabel)
	}

    // MARK: Buttons

    @IBAction func dismissButtonPressed(_ sender: Any) {
		viewModel.dismissTapped()
    }

    @IBAction func downArrowButtonPressed(_ sender: Any) {
		viewModel.dismissTapped()
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(true, animated: animated)
	}

	// Delegates passed down from the InitialViewCoordinator.
	func dataIsReady() {
		dismissButton.isHidden.toggle()
		dismissArrowButton.isHidden.toggle()
		dismissButton.isEnabled.toggle()
		dismissArrowButton.isEnabled.toggle()
		activityMonitor.stopAnimating()
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

class AVPlayerView: UIView {
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}

public extension UIAlertController {
    func show() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = UIViewController()
		viewController.view.backgroundColor = .clear
		window.rootViewController = viewController
		window.windowLevel = UIWindow.Level.alert + 1
		window.makeKeyAndVisible()
		viewController.present(self, animated: true, completion: nil)
    }
}
