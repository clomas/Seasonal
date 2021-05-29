//
//  _MenuBarViewModel.swift
//  Seasonal
//
//  Created by Clint Thomas on 20/11/20.
//  Copyright © 2020 Clint Thomas. All rights reserved.
//

import Foundation
import UIKit

protocol _MenuBarDelegate: AnyObject {
	func menuBarTapped(at index: Int)
}

final class _MenuBarViewModel {

	var menuBarCells: [_MenuBarCellModel] = []
	var delegate: _MenuBarDelegate?
	var onUpdate = {}
	var selectedView: ViewDisplayed?
	var mainViewIconSelected: ViewDisplayed?
	var selectedCategory: ViewDisplayed.ProduceCategory?

	init(month: Month?, season: Season?, viewDisplayed: ViewDisplayed) {
		mainViewIconSelected = viewDisplayed
		selectedView = viewDisplayed
		switch viewDisplayed {
		case .months, .favourites:
			if let month = month {
				setupMainViewMenuBar(selected: viewDisplayed, month: month)
			}
		case .seasons:
			if let season = season {
				setupSeasonsViewMenuBar(season: season)
			}
		case .monthPicker:
			break
		}
	}

	func menuBarTapped(at index: Int) {
		toggleSelectedCells(indexSelected: index)
		// keep track of the current view for when cancel is tapped
		if index <= ViewDisplayed.seasons.rawValue {
			selectedView = ViewDisplayed.init(rawValue: index)
			// Hold value in mainViewIconSelected for navigating backwards to mainViewController
			if index == ViewDisplayed.months.rawValue || index == ViewDisplayed.favourites.rawValue {
				mainViewIconSelected = ViewDisplayed(rawValue: index)
			}
		} else {
			selectedCategory = ViewDisplayed.ProduceCategory.init(rawValue: index)
		}
		delegate?.menuBarTapped(at: index)
		onUpdate()
	}


	/// This is called if cancel is tapped in the category slide over of the menu bar.
	/// It's require to toggle the index back to the current selected view
	func categoryWasCancelledAnimationFinished() {
		if let index = selectedView?.rawValue {
			toggleSelectedCells(indexSelected: index)
		}
	}

	func toggleSelectedCells(indexSelected: Int) {
		self.menuBarCells[indexSelected].isSelected = true
		for index in 0..<self.menuBarCells.count where index != indexSelected {
			self.menuBarCells[index].isSelected = false
		}
	}
}

extension _MenuBarViewModel {

	// For MainView
	func setupMainViewMenuBar(selected: ViewDisplayed, month: Month) {
		var constraints: (String, String)
		var selectedCell = false

		for index in 0...8 {
			if index == selected.rawValue {
				selectedCell = true
			} else {
				selectedCell = false
			}

			if index == 2 {
				constraints = ("H:[v0(45)]", "V:[v0(43)]")
			} else {
				constraints = ("H:[v0(61)]", "V:[v0(49)]")
			}

			guard let imageName = _MenuBarModel.Months.init(rawValue: index)?.imageName(currentMonth: month) else { return }
			self.menuBarCells.append(_MenuBarCellModel(menuBarItem: _MenuBarItem(imageName: imageName,
																		selected: selectedCell,
																		   constraints: constraints)))
		}
	}

	// For Seasons View
	func setupSeasonsViewMenuBar(season: Season?) {
		for index in 0...8 {
			var selectedCell: Bool = false
			if index < Season.allCases.count {
				if let season = season {
					if index == season.rawValue {
						selectedCell = true
					}
				}
			}

			guard let imageName = _MenuBarModel.Seasons.init(rawValue: index)?.imageName else { return }
			self.menuBarCells.append(_MenuBarCellModel(menuBarItem: _MenuBarItem(imageName: imageName(), selected: selectedCell, constraints: ("H:[v0(61)]", "V:[v0(49)]"))))
		}
	}
}

