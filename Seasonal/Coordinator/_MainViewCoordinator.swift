//
//  _MainViewCoordinator.swift
//  Seasonal
//
//  Created by Clint Thomas on 21/2/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import Foundation
import UIKit

// Keep track of the current View that is shown
// The integers match up with the index of the menuBar buttons
enum ViewDisplayed: Int {
	case favourites = 0
	case monthPicker = 1
	case months = 2
	case seasons = 3

	enum ProduceCategory: Int, CaseIterable {
		case all = 4
		case fruit = 5
		case vegetables = 6
		case herbs = 7
		case cancelled = 8
	}
}

protocol MonthSelectedDelegate: AnyObject {
	func updateMonth(to month: Month?)
}

// TODO: accessibility - https://medium.com/capital-one-tech/building-accessible-ios-apps-827c3469a3e9

final class _MainViewCoordinator: NSObject, _Coordinator, UINavigationControllerDelegate, UIGestureRecognizerDelegate {

	var parentCoordinator: _AppCoordinator?
	private(set) var childCoordinators: [_Coordinator] = []

	weak var monthSelectedDelegate: MonthSelectedDelegate?
	private var dataFetched: [Produce]?
	private var determinedLocation: StateLocation

	private let navigationController: UINavigationController
	private var modalNavigationController: UINavigationController?

	init(navigationController: UINavigationController, dataFetched: [Produce], location: StateLocation) {
		self.navigationController = navigationController
		self.dataFetched = dataFetched
		self.determinedLocation = location
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
											   category: .all,
											   searchString: "")

		mainViewModel.coordinator = self
		mainViewController.viewModel = mainViewModel

		// change animation to slide up
		//navigationController.

		let fromTopTransition = setUpNavigationTransition()
		navigationController.view.layer.add(fromTopTransition, forKey: kCATransition)
		navigationController.pushViewController(mainViewController, animated: true)
	}

	// Handle all navigation options

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

	// MARK: Presenting ViewControllers

	// Month Picker View Controller

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

	// Seasons View Controller

	//https://benoitpasquier.com/coordinator-pattern-navigation-back-button-swift/
	func presentSeasonsViewController() {
		let seasonsViewController: _SeasonsViewController = .instantiate()
		guard let produceData = dataFetched else {
			return
		}

		let seasonsViewModel = _SeasonsViewModel(produceData: produceData.sortIntoSeasons(),
												 season: findCurrentSeason() ,
												 category: .all,
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

	func presentInfoViewController() {
		self.modalNavigationController = UINavigationController()
		let infoViewController: _InfoViewController = .instantiate()
		infoViewController.viewModel = _InfoViewModel(location: determinedLocation)
		modalNavigationController?.setViewControllers([infoViewController], animated: false)

		if let modalNavigationController = modalNavigationController {
			self.navigationController.present(modalNavigationController, animated: true, completion: nil)
		}
	}

	// View will slide up rather than default animation
	func setUpNavigationTransition() -> CATransition {
		let transition = CATransition()
		transition.duration = 0.5
		transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
		transition.type = CATransitionType.reveal
		transition.subtype = CATransitionSubtype.fromTop
		return transition
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
 }
