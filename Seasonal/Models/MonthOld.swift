//
//  Month.swift
//  Seasonal
//
//  Created by Clint Thomas on 9/4/2023.
//  Copyright © 2023 Clint Thomas. All rights reserved.
//

import Foundation

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

enum Month: Int, CaseIterable {
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

	var firstLetter: String {
		"\(self)".first?.uppercased() ?? ""
	}
}
