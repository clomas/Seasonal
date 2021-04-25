//
//  _MenuBarCellViewModel.swift
//  Seasonal
//
//  Created by Clint Thomas on 11/3/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import Foundation

struct _MenuBarCellViewModel {
	var menuBarItem: MenuBarItem!

	init(menuBarItem: MenuBarItem) {
		self.menuBarItem = menuBarItem
	}

	var imageName: String {
		return self.menuBarItem.imageName
	}
	var constraints: (String, String) {
		return self.menuBarItem.constraints
	}

	var isSelected: Bool {
		get {
			return self.menuBarItem.selected
		} set(selected) {
			self.menuBarItem.selected = selected
		}
	}
}


