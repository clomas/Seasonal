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
		static var inSeasonTint: UIColor { return UIColor(named: Constants.inSeasonColor)! }
		static var nonSeasonTint: UIColor { return UIColor(named: Constants.nonSeasonColor)! }
	}

	struct LikeButton {
		static var tint: UIColor { return UIColor(named: Constants.likeButtonColor)! }
	}

	struct MenuBar {
		static var tint: UIColor { return UIColor(named: Constants.menuBarColor)! }
		static var selectedTint: UIColor { return UIColor(named: Constants.menuBarSelectedColor)! }
	}

	struct NavigationBar {
		static var tint: UIColor { return UIColor(named: Constants.navigationBarColor)! }
	}

	struct SearchBar {
		static var tint: UIColor { return UIColor(named: Constants.searchBarColor)! }
	}

	struct TableViewCell {
		static var tint: UIColor { return UIColor(named: Constants.tableViewCellColor)! }
	}
}
