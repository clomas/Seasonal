//
//  Months.swift
//  Seasonal
//
//  Created by Clint Thomas on 20/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

enum Months: Int, PeriodType {

	case january = 1
	case february
	case march
	case april
	case may
	case june
	case july
	case august
	case september
	case october
	case november
	case december

	static let currentPeriod: Months = Months(rawValue: Calendar.current.component(.month, from: Date())) ?? .december

	var index: CGFloat {
		CGFloat(self.rawValue)
	}

	var image: Image {
		.calendar
	}

	var firstLetter: String {
		"\(self)".first?.uppercased() ?? ""
	}
}

