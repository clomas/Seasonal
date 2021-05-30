//
//  WelcomeCardVC.swift
//  Seasonal
//
//  Created by Clint Thomas on 3/8/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//

import UIKit

class WelcomeCardVC: UIViewController {

    @IBOutlet weak var cardView: UIView!
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted: CGFloat = 0
    var interactor: Interactor

    override func viewDidLoad() {
        super.viewDidLoad()
        // let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleCardPan(recognizer:)))
        // let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(recognizer:)))

        // cardView.addGestureRecognizer(panGestureRecognizer)

        self.view.clipsToBounds = true
        cardView.clipsToBounds = true
        cardView.layer.cornerRadius = 20
        self.definesPresentationContext = true
        self.providesPresentationContextTransitionStyle = true

    }
    @IBAction func handleGesture(_ sender: UIPanGestureRecognizer) {

        let percentThreshold: CGFloat = 0.3

        // convert y-position to downward pull progress (percentage)
        let translation = sender.translation(in: view)
        let verticalMovement = translation.y / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)

        guard let interactor = interactor else { return }

        switch sender.state {
        case .began:
            interactor.hasStarted = true
            dismiss(animated: true, completion: nil)
        case .changed:
            interactor.shouldFinish = progress > percentThreshold
            interactor.update(progress)
        case .cancelled:
            interactor.hasStarted = false
            interactor.cancel()
        case .ended:
            interactor.hasStarted = false
            interactor.shouldFinish
                ? interactor.finish()
                : interactor.cancel()
        default:
            break
        }
    }

    @IBAction func downArrowPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
