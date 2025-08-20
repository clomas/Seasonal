//
//  Extension-UIColor.swift
//  Seasonal
//
//  Created by Clint Thomas on 29/4/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import UIKit

// For more easily readable color tints

extension UIColor {

	struct MonthIcon {
		static var inSeasonTint: UIColor { return UIColor(named: Constants.inSeasonColor) ?? UIColor() }
		static var nonSeasonTint: UIColor { return UIColor(named: Constants.nonSeasonColor) ?? UIColor() }
	}

	struct LikeButton {
		static var tint: UIColor { return UIColor(named: Constants.likeButtonColor) ?? UIColor() }
	}

	struct MenuBar {
		static var tint: UIColor { return UIColor(named: Constants.menuBarColor) ?? UIColor() }
		static var selectedTint: UIColor { return UIColor(named: Constants.menuBarSelectedColor) ?? UIColor() }
	}

	struct NavigationBar {
		static var tint: UIColor { return UIColor(named: Constants.navigationBarColor) ?? UIColor() }
	}

	struct SearchBar {
		static var tint: UIColor { return UIColor(named: Constants.searchBarColor) ?? UIColor() }
	}

	struct TableViewCell {
		static var tint: UIColor { return UIColor(named: Constants.tableViewCellColor) ?? UIColor() }
	}
}
