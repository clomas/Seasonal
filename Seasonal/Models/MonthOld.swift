	//
	//  Month.swift
	//  Seasonal
	//
	//  Created by Clint Thomas on 9/4/2023.
	//  Copyright © 2023 Clint Thomas. All rights reserved.
	//

import SwiftUI

enum MonthOld: Int, CaseIterable {
	case decemberOverflow
	case january
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
	case januaryOverflow

	var firstLetter: String {
		"\(self)".first?.uppercased() ?? ""
	}
}

enum Month: Int, PeriodType {
	case january
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

	static let thisMonth: Month = Month(rawValue: Calendar.current.component(.month, from: Date())) ?? .december
	
	var image: Image {
		.calendar
	}

	var firstLetter: String {
		"\(self)".first?.uppercased() ?? ""
	}
}

extension Calendar {

	func isDateInThisMonth(_ date: Date) -> Bool {
		isDate(date, equalTo: Date(), toGranularity: .month)
	}
}
