//
//  _WelcomeViewController.swift
//  Seasonal
//
//  Created by Clint Thomas on 11/1/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//

import UIKit
import AVFoundation

class _WelcomeViewController: UIViewController, InitialViewDelegate {

	var parentCoordinator: _InitialViewCoordinator?
	var viewModel: _WelcomeViewModel!

    @IBOutlet weak var activityMonitor: UIActivityIndicatorView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var dismissArrowButton: UIButton!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var AVPlayerView: AVPlayerView!

    private var player: AVPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
		parentCoordinator?.initialViewDelegate = self
    }

    private func setupViews() {
		welcomeLabel.text = viewModel.welcomeLabel
		activityMonitor.startAnimating()
		activityMonitor.hidesWhenStopped = true
		dismissButton.isHidden = true
		dismissArrowButton.isHidden = true
		dismissButton.isEnabled = false
		dismissArrowButton.isEnabled = false

		// check if dark mode
		if traitCollection.userInterfaceStyle == .dark {
			viewModel.videoName = "darkwelcomevideo"
		}
		playVideo()
    }

    // MARK: Video

    private func playVideo() {
        guard let path = Bundle.main.path(forResource: viewModel.videoName, ofType: "mp4") else {
            debugPrint("video not found")
            return
        }
        player = AVPlayer(url: URL(fileURLWithPath: path))
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: .mixWithOthers)
             try AVAudioSession.sharedInstance().setActive(true)
        } catch {
             print(error)
        }
        
        let castedLayer = AVPlayerView.layer as! AVPlayerLayer
        castedLayer.player = player
        castedLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        //player.volume = 0
        //player.actionAtItemEnd = .none
        player.play()

        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }

    // Start video over after completion
    @objc func playerItemDidReachEnd(notification: Notification) {
        if let playerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: CMTime.zero, completionHandler: nil)
        }
    }

    // MARK: Animations

    private func animateLabel() {
        if self.dismissButton.isHidden == false {
            self.activityMonitor.isHidden = true
        }
        self.welcomeLabel.alpha = 0.0
        UIView.animate(withDuration: 0.9, animations: {() -> Void in
			self.welcomeLabel.text = self.viewModel.welcomeLabel
            self.welcomeLabel.alpha = 1
        }, completion: { finished in
            UIView.animate(withDuration: 3, animations: {() -> Void in
            }, completion: { finished in
                UIView.animate(withDuration: 2, animations: {() -> Void in
                    self.welcomeLabel.alpha = 0.0
                }, completion: { finished in
                    if finished {
                        self.welcomeLabel.text = "Swipe between months and\n filter by category"
                        UIView.animate(withDuration: 0.3, animations: {
                            self.welcomeLabel.alpha = 1
                        })
                        DispatchQueue.global(qos: .utility).async {
                            DispatchQueue.global(qos: .default).async {
                            }
                        }
                    }
                })
            })
        })
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

	// Delegates passed down from the AppEntryCoordinator.

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
		// TODO: create a flag for this in userdefaults for boolean.
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

class AVPlayerView: UIView {
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}

public extension UIAlertController {
    func show() {
        let win = UIWindow(frame: UIScreen.main.bounds)
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        win.rootViewController = vc
        win.windowLevel = UIWindow.Level.alert + 1
        win.makeKeyAndVisible()
        vc.present(self, animated: true, completion: nil)
    }
}
