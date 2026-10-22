//
//  Extension-String.swift
//  Seasonal
//
//  Created by Clint Thomas on 29/4/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import Foundation

extension String {

	/// Creates titles for ViewControllers
	/// - Parameter category: uses the produce category in the title
	/// - Returns: complete string for title
	func createTitleString(with category: ViewDisplayed.ProduceCategory) -> String {

		var titleString: String = self.capitalized

		if category != .cancelled && category != .all {
			titleString = "\(category.asString.capitalized) in \(titleString)"
		}
		return titleString
	}
}
