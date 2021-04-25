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
	func updateMonth(to month: Month)
}
// TODO: DO I need a parent coordinator here?

final class _MainViewCoordinator: _Coordinator {

	private(set) var childCoordinators: [_Coordinator] = []
	private let navigationController: UINavigationController
	private var modalNavigationController: UINavigationController?
	var parentCoordinator: _AppEntryCoordinator?
	var dataFetched: [Produce]?
	var monthSelectedDelegate: MonthSelectedDelegate?


	init(navigationController: UINavigationController, dataFetched: [Produce]) {
		self.navigationController = navigationController
		self.dataFetched = dataFetched
	}

	func start() {
		let mainViewController: _MainViewController = .instantiate()
		guard let produceData = dataFetched else {
			return
		}

		let mainViewModel = _MainViewModel(monthsProduce: produceData.sortIntoMonths(),
											   favouritesProduce: produceData.sortIntoFavourites(),
											   viewDisplayed: .months,
											   month: findCurrentMonth(),
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

	func monthPickerFinished(display month: Month) {
		monthSelectedDelegate?.updateMonth(to: month)
	}

	func presentMonthPickerViewController() {
		self.modalNavigationController = UINavigationController()
		let monthPickerViewController: _MonthPickerViewController = .instantiate()
		modalNavigationController?.setViewControllers([monthPickerViewController], animated: false)
		monthPickerViewController.coordinator = self

		if let modalNavigationController = modalNavigationController {
			navigationController.present(modalNavigationController, animated: true, completion: nil)
		}
	}

	//https://benoitpasquier.com/coordinator-pattern-navigation-back-button-swift/
	func presentSeasonsViewController() {
		let seasonsViewController: _SeasonsViewController = .instantiate()
		guard let produceData = dataFetched else {
			return
		}

		let seasonsViewModel = _SeasonsViewModel(produceData: produceData.sortIntoSeasons(),
												 season: findCurrentSeason() ,
												 filter: .cancelled,
												 searchString: "")

		seasonsViewModel.coordinator = self
		seasonsViewController.viewModel = seasonsViewModel

		// change animation to slide up
		//navigationController.

		let fromTopTransition = setUpNavigationTransition()
		navigationController.view.layer.add(fromTopTransition, forKey: kCATransition)
		navigationController.pushViewController(seasonsViewController, animated: true)
	}

	func findCurrentMonth() -> Month {
		let monthAndSeason = DateHandler().findMonthAndSeason()
		return monthAndSeason.0
	}

	func findCurrentSeason() -> Season {
		let monthAndSeason = DateHandler().findMonthAndSeason()
		return monthAndSeason.1
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
 }
