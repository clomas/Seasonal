//
//  MenuBarCellViewModel.swift
//  Seasonal
//
//  Created by Clint Thomas on 11/3/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import Foundation

struct MenuBarCellModel {

	var menuBarItem: MenuBarItem!

	init(menuBarItem: MenuBarItem) {
		self.menuBarItem = menuBarItem
	}

	var imageName: String {
		get {
			return menuBarItem.imageName
		} set (imageUpdate) {
			menuBarItem.imageName = imageUpdate
		}
	}
	var constraints: (String, String) {
		return menuBarItem.constraints
	}

	var isSelected: Bool {
		get {
			return menuBarItem.selected
		} set(selected) {
			menuBarItem.selected = selected
		}
	}
}

struct MenuBarItem {
	var imageName: String
	var selected: Bool
	var constraints: (String, String)
}
