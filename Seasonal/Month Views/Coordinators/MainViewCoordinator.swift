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

final class MainViewCoordinator: NSObject, Coordinator, UINavigationControllerDelegate, UIGestureRecognizerDelegate {

	private let navigationController: UINavigationController
	private var modalNavigationController: UINavigationController?

	var parentCoordinator: AppCoordinator?
	var cloudKitDataService: CloudKitDataService?

	weak var monthSelectedDelegate: MonthSelectedDelegate?

	private var mainViewController: MainViewController?
	private var dataFetched: [ProduceModel]?
	private var determinedLocation: StateLocation
	private var monthAndSeason: (Month, Season) = DateHandler().findMonthAndSeason()
	private var currentMonth: Month { monthAndSeason.0 }
	private var currentSeason: Season { monthAndSeason.1 }

	init(navigationController: UINavigationController,
		 cloudKitDataService: CloudKitDataService,
		 dataFetched: [ProduceModel]?,
		 location: StateLocation) {
		self.navigationController = navigationController
		self.cloudKitDataService = cloudKitDataService
		self.dataFetched = dataFetched
		self.determinedLocation = location
	}

	func start() {
		navigationController.delegate = self
		mainViewController = .instantiate()

		let monthNow: Month = currentMonth
		let mainViewModel: MainViewModel = MainViewModel(monthsProduce: dataFetched?.sortIntoMonths(),
														 favouritesProduce: dataFetched?.sortIntoFavourites(),
														 viewDisplayed: .months,
														 monthToDisplay: monthNow,
														 previousMonth: monthNow,
														 thisMonthForProduceCell: monthNow,
														 category: .all,
														 searchString: ""
		)
		mainViewModel.coordinator = self
		mainViewController?.viewModel = mainViewModel

		// change animation to slide up
		// navigationController.
		let fromTopTransition: CATransition = setUpNavigationTransition()
		navigationController.view.layer.add(fromTopTransition, forKey: kCATransition)

		if let mainViewControllerToPresent: UIViewController = mainViewController {
			navigationController.pushViewController(mainViewControllerToPresent, animated: true)
		}
	}

	// MARK: Navigation

	func seasonsBackButtonTapped() {
		navigationController.popViewController(animated: true)
	}

	// Handle all navigation options
	func menuBarTappedWasForNavigation(at index: Int) {
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

	func monthPickerFinished(display month: Month?) {
		monthSelectedDelegate?.updateMonth(to: month ?? nil)
	}

	func presentInfoViewController() {
		guard let infoViewController: InfoViewController = .instantiate() else { return }
		infoViewController.viewModel = InfoViewModel(location: determinedLocation)
		infoViewController.viewModel?.coordinator = self

		modalNavigationController = UINavigationController()
		modalNavigationController?.setViewControllers([infoViewController], animated: false)

		if let modalNavigationController: UINavigationController = modalNavigationController {
			navigationController.present(modalNavigationController, animated: true, completion: nil)
		}
	}

	func updateDataModelsAndDatabase(for id: Int, liked: Bool, from view: ViewDisplayed) {

		if view == .seasons {
			mainViewController?.viewModel?.likeToggle(id: id, liked: liked)
		} else {
			// update the struct array that is passed to SeasonsView which is pushed and popped
			if let index: Array<Produce>.Index = dataFetched?.firstIndex(where: { $0.id == id}) {
				dataFetched?[index].liked = liked
			}
		}

		if liked {
			addLikedProduceToCloudKitDatabase(id: id)
		} else {
			removeLikedProduceToCloudKitDatabase(id: id)
		}
	}

	// MARK: Presenting ViewControllers
	// Month Picker View Controller

	private func presentMonthPickerViewController() {
		guard let monthPickerViewController: MonthPickerViewController = .instantiate() else { return }
		modalNavigationController = UINavigationController()

		modalNavigationController?.setViewControllers([monthPickerViewController], animated: false)
		monthPickerViewController.coordinator = self

		if let modalNavigationController: UINavigationController = modalNavigationController {
			navigationController.present(modalNavigationController, animated: true, completion: nil)
		}
	}

	// Seasons View Controller

	private func presentSeasonsViewController() {
		guard let seasonsViewController: SeasonsViewController = .instantiate(),
			  let produceData = dataFetched else {
			return
		}

		let seasonsViewModel: SeasonsViewModel = SeasonsViewModel(produceData: produceData.sortIntoSeasons(),
																  season: currentSeason,
																  category: .all,
																  searchString: ""
		)
		seasonsViewModel.coordinator = self
		seasonsViewController.viewModel = seasonsViewModel

		navigationController.interactivePopGestureRecognizer?.delegate = self
		navigationController.interactivePopGestureRecognizer?.isEnabled = true
		navigationController.pushViewController(seasonsViewController, animated: true)
	}

	private func addLikedProduceToCloudKitDatabase(id: Int) {
		cloudKitDataService?.saveLikeToPrivateDatabaseInCloudKit(id: id) { (result: Result<Bool, CloudKitError>) in
			#if DEBUG
			if result == .success(true) {
				print(result, "added like record in CloudKit - id: \(id)")
			} else {
				print(result)
			}
			#endif
			// TODO: Handle error here
		}
	}

	private func removeLikedProduceToCloudKitDatabase(id: Int) {
		cloudKitDataService?.deleteRecordsInPrivateDatabase(id: id) { (result: Result<Bool, CloudKitError>) in
			#if DEBUG
			if result == .success(true) {
				print(result, "removed like record in CloudKit - id: \(id)")
			} else {
				print(result)
			}
			#endif
			// TODO: Handle error here
		}
	}

	// View will slide up rather than default animation
	private func setUpNavigationTransition() -> CATransition {
		let transition: CATransition = CATransition()
		transition.duration = 0.5
		transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
		transition.type = CATransitionType.reveal
		transition.subtype = CATransitionSubtype.fromTop

		return transition
	}
 }
