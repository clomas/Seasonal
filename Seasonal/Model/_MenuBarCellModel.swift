//
//  _MenuBarCellModel.swift
//  Seasonal
//
//  Created by Clint Thomas on 9/3/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import Foundation

struct _MenuBarCellModel {
	var menuBarItem: MenuBarItem!

	init(menuBarItem: MenuBarItem) {
		self.menuBarItem = menuBarItem
	}

	var imageName: String {
		get {
			return self.menuBarItem.imageName
		} set (imageUpdate) {
			self.menuBarItem.imageName = imageUpdate
		}
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

