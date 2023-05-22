//
//  MenuBarViewModel.swift
//  Seasonal
//
//  Created by Clint Thomas on 20/11/20.
//  Copyright © 2020 Clint Thomas. All rights reserved.
//

import Foundation
import UIKit

protocol MenuBarDelegate: AnyObject {
	func menuBarWasTapped(at index: Int)
}

final class MenuBarViewModel {

	var menuBarCells: [MenuBarCellModel] = []

	private var selectedMonthView: MenuBarModel.Months?
	private var selectedMonth: Month?
	private var selectedSeasonView: MenuBarModel.Seasons?

	weak var delegate: MenuBarDelegate?

	init(month: Month, viewDisplayed: MenuBarModel.Months) {
		self.selectedMonth = month
		self.selectedMonthView = viewDisplayed
		self.selectedSeasonView = nil

		setupMainViewMenuBar()
		setupSelectedCell(selectedMenuBarIndex: selectedMonthView?.rawValue)
	}

	init(season: Season) {
		self.selectedSeasonView = MenuBarModel.Seasons(rawValue: season.rawValue)
		self.selectedMonthView = nil

		setupSeasonsViewMenuBar()
		setupSelectedCell(selectedMenuBarIndex: selectedSeasonView?.rawValue)
	}

	func menuBarWasTapped(at index: Int) {
		// if cancel is selected the indexToSelect needs to be the previous category
		var indexToSelect: Int = index

		switch index {
		// change `categories` to `all`
		case MenuBarModel.Months.all.rawValue:
			menuBarCells[index].imageName = MenuBarModel.CategoryLabel.altLabel.imageName()

		// change `all` back to `categories`
		case MenuBarModel.Months.cancel.rawValue:
			menuBarCells[ViewDisplayed.ProduceCategory.all.rawValue].imageName = MenuBarModel.CategoryLabel.categories.imageName()

			indexToSelect = selectedMonthView?.rawValue ?? selectedSeasonView?.rawValue ?? 0

		// category was selected - toggle with index
		case MenuBarModel.Months.all.rawValue...MenuBarModel.Months.herbs.rawValue:
			break

		// favourite / months / season selected
		default:
			if let monthView: MenuBarModel.Months = MenuBarModel.Months(rawValue: index), selectedMonthView != nil {
				selectedMonthView = monthView
			} else if let seasonsView: MenuBarModel.Seasons = MenuBarModel.Seasons(rawValue: index), selectedSeasonView != nil {
				selectedSeasonView = seasonsView
			}
		}

		toggleSelectedCells(indexSelected: indexToSelect)
		delegate?.menuBarWasTapped(at: index)
	}

	private func toggleSelectedCells(indexSelected: Int) {
		menuBarCells[indexSelected].isSelected = true

		for index in 0..<menuBarCells.count where index != indexSelected {
			menuBarCells[index].isSelected = false
		}
	}

	private func setupSelectedCell(selectedMenuBarIndex: Int?) {
		menuBarCells[selectedMenuBarIndex ?? 0].isSelected = true
	}
}

extension MenuBarViewModel {

	// For MainView
	func setupMainViewMenuBar() {
		var constraints: (String, String)
		var selectedCell: Bool = false

		for index in 0...8 {
			selectedCell = index == selectedMonthView?.rawValue
			constraints = index == ViewDisplayed.months.rawValue ? ("H:[v0(45)]", "V:[v0(43)]") : ("H:[v0(61)]", "V:[v0(49)]")

			guard let imageName: String = MenuBarModel.Months(rawValue: index)?.imageName(currentMonth: selectedMonth ?? .december) else { return }
			menuBarCells.append(MenuBarCellModel(menuBarItem: MenuBarItem(imageName: imageName, selected: selectedCell, constraints: constraints)))
		}
	}

	// For Seasons View
	func setupSeasonsViewMenuBar() {
		let constraints: (String, String) = ("H:[v0(61)]", "V:[v0(49)]")

		for index in 0...8 {
			var selectedCell: Bool = false

			if index < Season.allCases.count {
				if let season: MenuBarModel.Seasons = selectedSeasonView, index == season.rawValue {
					selectedCell = true
				}
			}

			guard let imageName: String = MenuBarModel.Seasons(rawValue: index)?.imageName() else { return }
			menuBarCells.append(MenuBarCellModel(menuBarItem: MenuBarItem(imageName: imageName, selected: selectedCell, constraints: constraints)))
		}
	}
}
