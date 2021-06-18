//
//  MainViewCoordinator.swift
//  Seasonal
//
//  Created by Clint Thomas on 21/2/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//
// The MainView has no children coordinators. I could have made
// one for SeasonsView however, it this class isn't massive.

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
final class MainViewCoordinator: NSObject, Coordinator, UINavigationControllerDelegate, UIGestureRecognizerDelegate {

	var parentCoordinator: AppCoordinator?
	private(set) var childCoordinators: [Coordinator] = [] // No Children

	private let navigationController: UINavigationController
	private var modalNavigationController: UINavigationController?

	var cloudKitDataService: CloudKitDataService?

	weak var monthSelectedDelegate: MonthSelectedDelegate?

	private var dataFetched: [Produce]?
	private var determinedLocation: StateLocation
	private var monthAndSeason = DateHandler().findMonthAndSeason()

	var currentMonth: Month { return monthAndSeason.0 }
	var currentSeason: Season { return monthAndSeason.1	}

	let mainViewController: MainViewController = .instantiate()
	let produceDataService = ProduceDataService()

	init(navigationController: UINavigationController,
		 cloudKitDataService: CloudKitDataService,
		 dataFetched: [Produce],
		 location: StateLocation) {
		self.navigationController = navigationController
		self.cloudKitDataService = cloudKitDataService
		self.dataFetched = dataFetched
		self.determinedLocation = location
	}

	func start() {
		self.navigationController.delegate = self
		guard let produceData = dataFetched else {
			return
		}
		let monthNow = currentMonth

		let mainViewModel = MainViewModel(monthsProduce: produceData.sortIntoMonths(),
											   favouritesProduce: produceData.sortIntoFavourites(),
											   viewDisplayed: .months,
											   monthToDisplay: monthNow,
											   currentMonth: monthNow,
											   previousMonth: monthNow,
											   category: .all,
											   searchString: "")

		mainViewModel.coordinator = self
		mainViewController.viewModel = mainViewModel

		// change animation to slide up
		// navigationController.

		let fromTopTransition = setUpNavigationTransition()
		navigationController.view.layer.add(fromTopTransition, forKey: kCATransition)
		navigationController.pushViewController(mainViewController, animated: true)
	}

	// Handle all navigation options

	func menuBarTappedForNavigation(at index: Int) {
		switch index {
		case ViewDisplayed.monthPicker.rawValue:
			self.presentMonthPickerViewController()
		case ViewDisplayed.monthPicker.rawValue:
			self.presentMonthPickerViewController()
		case ViewDisplayed.seasons.rawValue:
			self.presentSeasonsViewController()
		default:
			break
		}
	}

	// MARK: Presenting ViewControllers

	// Month Picker View Controller

	func presentMonthPickerViewController() {
		self.modalNavigationController = UINavigationController()
		let monthPickerViewController: MonthPickerViewController = .instantiate()
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
		let seasonsViewController: SeasonsViewController = .instantiate()
		guard let produceData = dataFetched else {
			return
		}

		let seasonsViewModel = SeasonsViewModel(
			produceData: produceData.sortIntoSeasons(),
			season: currentSeason,
			category: .all,
			searchString: ""
		)
		seasonsViewModel.coordinator = self
		seasonsViewController.viewModel = seasonsViewModel
		print("present")
		self.navigationController.interactivePopGestureRecognizer?.delegate = self
		self.navigationController.interactivePopGestureRecognizer?.isEnabled = true
		self.navigationController.pushViewController(seasonsViewController, animated: true)
	}

	func updateDataModels(for id: Int, liked: Bool, from view: ViewDisplayed) {
		// Update MainViewController's viewModel here - produce data is shared between
		// the two views Would love to know if theres a better way to do this
		// MainViewController is never removed from the NavigationController
		if view == .seasons {
			mainViewController.viewModel.likeToggle(id: id, liked: liked)
		} else {
			// update the struct array that is passed to SeasonsView which is pushed and popped
			if let index = dataFetched?.firstIndex(where: { $0.id == id}) {
				dataFetched?[index].liked = liked
			}
		}

		cloudKitDataService?.saveLikeToPrivateDatabaseInCloudKit(id: id) { result in
			print(result, "liked in CloudKit")
		}
	}

	func presentInfoViewController() {
		self.modalNavigationController = UINavigationController()
		let infoViewController: InfoViewController = .instantiate()
		infoViewController.viewModel = InfoViewModel(location: determinedLocation)
		infoViewController.viewModel.coordinator = self
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

	func seasonsBackButtonTapped() {
		print(self.navigationController.viewControllers)
		self.navigationController.popViewController(animated: true)
		print(self.navigationController.viewControllers)
	}
 }
