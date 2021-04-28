////
////  _CoordinatorNavigationController.swift
////  Seasonal
////
////  Created by Clint Thomas on 26/4/21.
////  Copyright © 2021 Clint Thomas. All rights reserved.
////
//// Thank you - https://medium.com/flawless-app-stories/flow-coordinator-pattern-on-steroids-a52021e31bfe
//
//import UIKit
//
//protocol CoordinatorNavigationControllerDelegate: class {
//	func didSelectCustomBackAction()
//	func transitionBackFinished()
//}
//
//class CoordinatorNavigationController: UINavigationController {
//
//	// MARK: Delegates
//
//	weak var swipeBackDelegate: CoordinatorNavigationControllerDelegate?
//
//	// MARK: - Vars & Lets
//
//	private var transition: UIViewControllerAnimatedTransitioning?
//	private var shouldEnableSwipeBack = false
//	fileprivate var duringPushAnimation = false
//
//	// MARK: Back button customisation
//
//	private var backButtonImage: UIImage?
//	private var backButtonTitle: String?
//	private var backButtonFont: UIFont?
//	private var backButtonTitleColor: UIColor?
//	private var shouldUseViewControllerTitles = false
//
//	override func viewDidLoad() {
//		super.viewDidLoad()
//		self.delegate = self
//	}
//
//	// MARK: - Public methods
//
//	func enableSwipeBack() {
//		self.shouldEnableSwipeBack = true
//		self.interactivePopGestureRecognizer?.isEnabled = true
//		self.interactivePopGestureRecognizer?.delegate = self
//	}
//
//	func customizeBackButton(backButtonImage: UIImage? = nil, backButtonTitle: String? = nil, backButtonFont: UIFont? = nil, backButtonTitleColor: UIColor? = nil, shouldUseViewControllerTitles: Bool = false) {
//		self.backButtonImage = backButtonImage
//		self.backButtonTitle = backButtonTitle
//		self.backButtonFont = backButtonFont
//		self.backButtonTitleColor = backButtonTitleColor
//		self.shouldUseViewControllerTitles = shouldUseViewControllerTitles
//	}
//
//	func customizeTitle(titleColor: UIColor, largeTextFont: UIFont, smallTextFont: UIFont, isTranslucent: Bool = true, barTintColor: UIColor? = nil) {
//		self.navigationBar.prefersLargeTitles = false
////		UINavigationBar.customNavBarStyle(color: titleColor, largeTextFont: largeTextFont, smallTextFont: smallTextFont, isTranslucent: isTranslucent, barTintColor: barTintColor)
//	}
//
//	// MARK: - Initialization
//
//	override init(rootViewController: UIViewController) {
//		super.init(rootViewController: rootViewController)
//	}
//
//	required init?(coder aDecoder: NSCoder) {
//		super.init(coder: aDecoder)
//	}
//
//	override func pushViewController(_ viewController: UIViewController, animated: Bool) {
//		self.duringPushAnimation = true
//		super.pushViewController(viewController, animated: animated)
//		self.setupCustomBackButton(viewController: viewController)
//	}
//
//	private func setupCustomBackButton(viewController: UIViewController) {
//		if self.backButtonImage != nil || self.backButtonTitle != nil {
//			viewController.navigationItem.hidesBackButton = true
//			let backButtonTitle = self.shouldUseViewControllerTitles ? self.viewControllers[self.viewControllers.count - 2].title : self.backButtonTitle
//			let button = CustomBackButton.initCustomBackButton(backButtonImage: self.backButtonImage, backButtonTitle: backButtonTitle, backButtonFont: self.backButtonFont, backButtonTitleColor: self.backButtonTitleColor)
//			button.addTarget(self, action: #selector(actionBack(sender:)), for: .touchUpInside)
//			viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
//		}
//	}
//	@objc private func actionBack(sender: UIBarButtonItem) {
//		self.swipeBackDelegate?.didSelectCustomBackAction()
//	}
//}
//
//// MARK: - Extensions
//// MARK: - UINavigationControllerDelegate
//extension CoordinatorNavigationController: UINavigationControllerDelegate {
//
//	func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//		return self.transition
//	}
//
//	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
//		if let coordinator = navigationController.topViewController?.transitionCoordinator {
//			coordinator.notifyWhenInteractionChanges { (context) in
//				if !context.isCancelled {
//					self.swipeBackDelegate?.transitionBackFinished()
//				}
//			}
//		}
//	}
//
//	func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
//		guard let swipeNavigationController = navigationController as? CoordinatorNavigationController else { return }
//
//		swipeNavigationController.duringPushAnimation = false
//	}
//
//}
//
//// MARK: - UIGestureRecognizerDelegate
//extension CoordinatorNavigationController: UIGestureRecognizerDelegate {
//
//	func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//		guard gestureRecognizer == self.interactivePopGestureRecognizer else {
//			return true
//		}
//
//		return self.viewControllers.count > 1 && self.duringPushAnimation == false
//	}
//
//
//	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//		return true
//	}
//
//}
//
//
//class CustomBackButton: UIButton {
//
//	static func initCustomBackButton(backButtonImage: UIImage? = nil, backButtonTitle: String? = nil, backButtonFont: UIFont? = nil, backButtonTitleColor: UIColor? = nil) -> UIButton {
//		let button = UIButton(type: .system)
//		if let backButtonImage = backButtonImage {
//			button.setImage(backButtonImage, for: .normal)
//		}
//		if let backButtonTitle = backButtonTitle {
//			button.setTitle(backButtonTitle, for: .normal)
//		}
//		if let backButtonFont = backButtonFont {
//			button.titleLabel?.font = backButtonFont
//		}
//		if let backButtonTitleColor = backButtonTitleColor {
//			button.setTitleColor(backButtonTitleColor, for: .normal)
//		}
//		return button
//	}
//
//}
