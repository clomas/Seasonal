//
//  WelcomeVC.swift
//  Seasonal
//
//  Created by Clint Thomas on 11/1/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//

import UIKit
import AVFoundation
import Network

class WelcomeVC: UIViewController, NetworkCheckObserver, Storyboarded {

    weak var coordinator: MainCoordinator?

    @IBOutlet weak var activityMonitor: UIActivityIndicatorView!
    private var dataLoaded = false
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var dismissArrowButton: UIButton!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var avPlayerView: AVPlayerView!
    var dismissButtonTappedCallback: (() -> Void)?
    private var player: AVPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        setUpVideo()
        startStopAnimations(start: true)
    }

    func startStopAnimations(start: Bool) {
        if start == true {
            activityMonitor.startAnimating()
            activityMonitor.hidesWhenStopped = true
            dismissButton.isHidden = true
            dismissArrowButton.isHidden = true
            dismissButton.isEnabled = false
            dismissArrowButton.isEnabled = false
        } else {
            dismissButton.isHidden.toggle()
            dismissArrowButton.isHidden.toggle()
            dismissButton.isEnabled.toggle()
            dismissArrowButton.isEnabled.toggle()
            activityMonitor.stopAnimating()
        }
    }

    // MARK: Video
    
    private func setUpVideo() {
        if traitCollection.userInterfaceStyle == .light {
            playVideo(videoName: "lightwelcomevideo")
        } else {
            playVideo(videoName: "darkwelcomevideo")
        }
    }

    private func playVideo(videoName: String) {
        guard let path = Bundle.main.path(forResource: videoName, ofType:"mp4") else {
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
        
        let castedLayer = avPlayerView.layer as! AVPlayerLayer
        castedLayer.player = player
        castedLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        player.volume = 0
        player.actionAtItemEnd = .none
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
            self.welcomeLabel.text = "Welome to Seasonal"
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

    func internetStatusDidChange(status: NWPath.Status) {
        if status == .satisfied {
            print("Interenet Connected")
            DispatchQueue.main.async {
                self.animateLabel()
            }
        }else if status == .unsatisfied {
            DispatchQueue.main.async {
                self.activityMonitor.isHidden = true
                self.activityMonitor.stopAnimating()
                self.welcomeLabel.text = "No Internet Connection!"
            }
        }
    }

    // MARK: Buttons

    @IBAction func dismissButtonPressed(_ sender: Any) {
        dismissButtonTappedCallback?()
    }
    
    @IBAction func downArrowButtonPressed(_ sender: Any) {
        dismissButtonTappedCallback?()
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

