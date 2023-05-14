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

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var dismissArrowButton: UIButton!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var AVPlayerView: AVPlayerView!

    private var player: AVPlayer!
	private var videoName: String {
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

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(true, animated: animated)
	}

    private func setupViews() {
		welcomeLabel.text = viewModel.welcomeLabel

		activityIndicator.startAnimating()
		activityIndicator.hidesWhenStopped = true

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
    @objc private func playerItemDidReachEnd(notification: Notification) {
        if let playerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: CMTime.zero, completionHandler: nil)
			playVideo()
        }
    }

    // MARK: Animations

	// TODO: nothing happens here
	private func animateWelcomeLabel() {
		if dismissButton.isHidden == false {
			activityIndicator.isHidden = true
		}
		welcomeLabel.animatedWelcomeLabel(initialLabelText: viewModel.welcomeLabel)
	}

    // MARK: Buttons

    @IBAction func dismissButtonPressed(_ sender: Any) {
		viewModel.dismissTapped()
    }

    @IBAction func downArrowButtonPressed(_ sender: Any) {
		viewModel.dismissTapped()
    }

	// Delegates passed down from the InitialViewCoordinator.
	func dataIsReady() {
		dismissButton.isHidden.toggle()
		dismissArrowButton.isHidden.toggle()
		dismissButton.isEnabled.toggle()
		dismissArrowButton.isEnabled.toggle()
		activityIndicator.stopAnimating()
	}

	func networkFailed() {
		presentAlert(title: "Network Error",
						  message: "Unable to connect to the internet",
						  alertStyle: .alert,
						  actionTitles: [],
						  actionStyles: [.default],
						  actions: []
		)
	}

	func locationNotFound() {
		presentLocationNotFoundAlert { [weak self] (state: StateLocation) in
			self?.viewModel.userChoseLocation(state: state)
		}
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
