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

	var viewModel: WelcomeViewModel?

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var dismissArrowButton: UIButton!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var AVPlayerView: AVPlayerView!

    private var player: AVPlayer!
	private var videoName: String {
		return traitCollection.userInterfaceStyle == .dark ? Constants.darkWelcomeVideo : Constants.lightWelcomeVideo
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		viewModel?.coordinator?.initialViewDelegate = self
        setupViews()
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
		activityIndicator.stopAnimating()
	}

	func networkFailed() {
		presentAlert(title: "Network Error",
					 message: "Unable to connect to the internet",
					 alertStyle: .alert,
					 actionTitles: ["Ok"],
					 actionStyles: [.default],
					 actions: []
		)
	}

	func locationNotFound() {
		presentLocationNotFoundAlert { [weak self] (state: StateLocation) in
			self?.viewModel?.userChoseLocation(state: state)
		}
	}

    private func setupViews() {
		welcomeLabel.text = viewModel?.welcomeLabel

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
			#if DEBUG
			print(error)
			#endif
			presentGenericAlert()
        }

		if let castedLayer: AVPlayerLayer = AVPlayerView.layer as? AVPlayerLayer {
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
		if let playerItem: AVPlayerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: CMTime.zero, completionHandler: nil)
			playVideo()
        }
    }

    // MARK: Animations

	private func animateWelcomeLabel() {
		if dismissButton.isHidden == false {
			activityIndicator.isHidden = true
		}
		welcomeLabel.animatedWelcomeLabel(initialLabelText: viewModel?.welcomeLabel ?? "")
	}

    // MARK: Buttons

    @IBAction func dismissButtonWasTapped(_ sender: Any) {
		viewModel?.dismissWasTapped()
    }
}

class AVPlayerView: UIView {
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}

private extension UILabel {

	// Pyramid of doom - not sure why I went with alpha = 0.999
	func animatedWelcomeLabel(initialLabelText: String) {
		alpha = 0.0

		UIView.animate(withDuration: 0.9, animations: { () -> Void in
			self.text = initialLabelText
			self.alpha = 1
		}, completion: { _ in
			UIView.animate(withDuration: 2, animations: { () -> Void in
				self.alpha = 0.999
			}, completion: { _ in
				UIView.animate(withDuration: 2, animations: { () -> Void in
					self.alpha = 0.0
				}, completion: { _ in
					self.text = "Swipe between months and\n filter by category"
					UIView.animate(withDuration: 0.3, animations: {
						self.alpha = 1
					}, completion: { _ in
						UIView.animate(withDuration: 2, animations: {
							self.alpha = 0.999
						}, completion: { _ in
							UIView.animate(withDuration: 2, animations: {
								self.alpha = 0
							}, completion: { finished in
								if finished {
									self.animatedWelcomeLabel(initialLabelText: initialLabelText)
								}
							})
						})
					})
				})
			})
		})
	}
}
