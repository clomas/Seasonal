//
//  Extension-Month.swift
//  Seasonal
//
//  Created by Clint Thomas on 29/4/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import Foundation

extension Month {

	static var asArray: [Month] { return self.allCases }

	var monthNameString: String {

		switch self {
		case .januaryOverflow:
			return String(describing: Month.january)
		case .decemberOverflow:
			return String(describing: Month.december)
		default:
			return String(describing: self)
		}
	}

	var calendarImageName: String {
		switch self {
		case .january: return "cal_jan.png"
		case .february: return "cal_feb.png"
		case .march: return "cal_mar.png"
		case .april: return "cal_apr.png"
		case .may: return "cal_may.png"
		case .june: return "cal_jun.png"
		case .july: return "cal_jul.png"
		case .august: return "cal_aug.png"
		case .september: return "cal_sep.png"
		case .october: return  "cal_oct.png"
		case .november: return "cal_nov.png"
		case .december: return "cal_dec.png"
		// Default case is due to this var not containing every option
		// given the overflow indexes for infinite month scrolling
		default: return "cal_dec.png"
		}
	}

	var imageName: String {
		switch self {
		case .january: return "jan_curr.png"
		case .february: return "feb_curr.png"
		case .march: return "mar_curr.png"
		case .april: return "apr_curr.png"
		case .may: return "may_curr.png"
		case .june: return "jun_curr.png"
		case .july: return "jul_curr.png"
		case .august: return "aug_curr.png"
		case .september: return "sep_curr.png"
		case .october: return "oct_curr.png"
		case .november: return "nov_curr.png"
		case .december: return "dec_curr.png"
		// As above
		default: return "dec_curr.png"
		}
	}
}
