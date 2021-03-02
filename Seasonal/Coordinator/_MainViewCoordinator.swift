//
//  _MainViewCoordinator.swift
//  Seasonal
//
//  Created by Clint Thomas on 21/2/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import Foundation
import UIKit

// TODO: DO I need a parent coordinator here?

final class _MainViewCoordinator: _Coordinator {

	private(set) var childCoordinators: [_Coordinator] = []
	private let navigationController: UINavigationController
	var parentCoordinator: Coordinator?
	var dataFetched: [Produce]?

	init(navigationController: UINavigationController, dataFetched: [Produce]) {
		self.navigationController = navigationController
		self.dataFetched = dataFetched
	}

	func start() {
		let mainViewContoller: _MainViewController = .instantiate()
		let monthsViewModel = _MonthsViewModel(produceData: dataFetched ?? [Produce](), viewDisplayed: .months, filter: .all, month: findCurrentMonth())
		let favouritesViewModel = _FavouritesViewModel(produceData: dataFetched ?? [Produce]())
		monthsViewModel.coordinator = self
		mainViewContoller.monthsViewModel = monthsViewModel
		mainViewContoller.favouritesViewModel = favouritesViewModel
		navigationController.pushViewController(mainViewContoller, animated: true)
	}

	func findCurrentMonth() -> Month {
		let monthAndSeason = DateHandler().findMonthAndSeason()
		return monthAndSeason.0
	}
 }
