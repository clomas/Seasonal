//
//  MenuBarViewModel.swift
//  Seasonal
//
//  Created by Clint Thomas on 20/11/20.
//  Copyright © 2020 Clint Thomas. All rights reserved.
//

import Foundation
import UIKit

final class MenuBarViewModel {

	var menuBarCells: [_MenuBarCellViewModel] = []

	init(selected: Int, month: Month, viewDisplayed: ViewDisplayed) {
		switch viewDisplayed {
		case .months:
			layoutMainViewMenuBar(selected: selected, month: month)
		case .seasons:
			layoutSeasonsViewMenuBar(selected: selected)
		default:
			layoutMainViewMenuBar(selected: selected, month: month)
		}
    }

    func selectDeselectCells(indexSelected: Int) {
        self.menuBarCells[indexSelected].isSelected = true

        for index in 0..<self.menuBarCells.count where index != indexSelected {
            self.menuBarCells[index].isSelected = false
        }
    }
}

extension MenuBarViewModel {

	// For MainView
	func layoutMainViewMenuBar(selected: Int, month: Month) {
		var constraints: (String, String)
		var selectedCell = false

		for index in 0...8 {
			if index == selected {
				selectedCell = true
			} else {
				selectedCell = false
			}

			if index == 2 {
				constraints = ("H:[v0(45)]", "V:[v0(43)]")
			} else {
				constraints = ("H:[v0(61)]", "V:[v0(49)]")
			}

			guard let imageName = MenuBarItems.Months.init(rawValue: index)?.imageName(currentMonth: month) else { return }
			self.menuBarCells.append(_MenuBarCellViewModel(menuBarItem: MenuBarItem(imageName: imageName,
																				   selected: selectedCell,
																				   constraints: constraints)))
		}
	}

	// For Seasons View
	func layoutSeasonsViewMenuBar(selected: Int) {
		var selectedCell: Bool

		for index in 0...8 {

			if index == selected {
				selectedCell = true
			} else {
				selectedCell = false
			}
			//self.menuBarCells.append(_MenuBarCellViewModel(menuBarItem: MenuBarItem(imageName: MenuBar.Seasons(rawValue: index)!.imageName(), selected: selectedCell, constraints: ("H:[v0(60)]", "V:[v0(48)]"))))
		}
	}
}


