//
//  _MainViewCoordinator.swift
//  Seasonal
//
//  Created by Clint Thomas on 21/2/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import Foundation
import UIKit

protocol MonthSelectedDelegate {
	func updateMonth(to month: Month?)
}
// TODO: DO I need a parent coordinator here?

final class _MainViewCoordinator: NSObject, _Coordinator, UINavigationControllerDelegate, UIGestureRecognizerDelegate {

	private(set) var childCoordinators: [_Coordinator] = []
	var navigationController: UINavigationController
	private var modalNavigationController: UINavigationController?
	var parentCoordinator: _AppEntryCoordinator?
	var dataFetched: [Produce]?
	var monthSelectedDelegate: MonthSelectedDelegate?

	init(navigationController: UINavigationController, dataFetched: [Produce]) {
		self.navigationController = navigationController
		self.dataFetched = dataFetched
	}

	func start() {
		self.navigationController.delegate = self
		let mainViewController: _MainViewController = .instantiate()
		guard let produceData = dataFetched else {
			return
		}

		let mainViewModel = _MainViewModel(monthsProduce: produceData.sortIntoMonths(),
											   favouritesProduce: produceData.sortIntoFavourites(),
											   viewDisplayed: .months,
											   month: findCurrentMonth(),
											   previousMonth: findCurrentMonth(),
											   filter: .all,
											   searchString: "")

		mainViewModel.coordinator = self
		mainViewController.viewModel = mainViewModel

		// change animation to slide up
		//navigationController.

		let fromTopTransition = setUpNavigationTransition()
		navigationController.view.layer.add(fromTopTransition, forKey: kCATransition)
		navigationController.pushViewController(mainViewController, animated: true)
	}

	func menuBarTappedForNavigation(at index: Int) {
		switch index {
		case ViewDisplayed.monthPicker.rawValue:
			presentMonthPickerViewController()
		case ViewDisplayed.monthPicker.rawValue:
			presentMonthPickerViewController()
		case ViewDisplayed.seasons.rawValue:
			presentSeasonsViewController()
		default:
			break
		}
	}

	func presentMonthPickerViewController() {
		self.modalNavigationController = UINavigationController()
		let monthPickerViewController: _MonthPickerViewController = .instantiate()
		modalNavigationController?.setViewControllers([monthPickerViewController], animated: false)
		monthPickerViewController.coordinator = self

		if let modalNavigationController = modalNavigationController {
			self.navigationController.present(modalNavigationController, animated: true, completion: nil)
		}
	}

	func monthPickerFinished(display month: Month?) {
		monthSelectedDelegate?.updateMonth(to: month ?? nil)
	}

	//https://benoitpasquier.com/coordinator-pattern-navigation-back-button-swift/
	func presentSeasonsViewController() {
		let seasonsViewController: _SeasonsViewController = .instantiate()
		guard let produceData = dataFetched else {
			return
		}

		let seasonsViewModel = _SeasonsViewModel(produceData: produceData.sortIntoSeasons(),
												 season: findCurrentSeason() ,
												 filter: .all,
												 searchString: "")

		seasonsViewModel.coordinator = self
		seasonsViewController.viewModel = seasonsViewModel
		seasonsViewController.coordinator = self

		// change animation to slide up
		//navigationController.
		self.navigationController.interactivePopGestureRecognizer?.delegate = self
		self.navigationController.interactivePopGestureRecognizer?.isEnabled = true
		self.navigationController.pushViewController(seasonsViewController, animated: true)
	}

	func findCurrentMonth() -> Month {
		let monthAndSeason = DateHandler().findMonthAndSeason()
		return monthAndSeason.0
	}

	func findCurrentSeason() -> Season {
		let monthAndSeason = DateHandler().findMonthAndSeason()
		return monthAndSeason.1
	}

	func seasonsBackButtonTapped() {
		self.navigationController.popViewController(animated: true)
	}

	// view will slide up rather than default animation
	func setUpNavigationTransition() -> CATransition {
		let transition = CATransition()
		transition.duration = 0.5
		transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
		transition.type = CATransitionType.reveal
		transition.subtype = CATransitionSubtype.fromTop
		return transition
	}

	// TODO: only need this for child coordinators

	func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
		// Read the view controller we’re moving from.
		guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
			return
		}

		print(navigationController.viewControllers)

		// Check whether our view controller array already contains that view controller. If it does it means we’re pushing a different view controller on top rather than popping it, so exit.
		if navigationController.viewControllers.contains(fromViewController) {
			print(fromViewController)
			return
		}

		if let window = UIApplication.shared.delegate?.window {
			if var viewController = window?.rootViewController {
				// handle navigation controllers
				if(viewController is UINavigationController){
					viewController = (viewController as! UINavigationController).visibleViewController!
				}
				print(viewController)
			}
		}

		// We’re still here – it means we’re popping the view controller, so we can check whether it’s a buy view controller

	}
 }
