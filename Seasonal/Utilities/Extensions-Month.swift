//
//  Extensions-Month.swift
//  Seasonal
//
//  Created by Clint Thomas on 29/4/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import Foundation

extension Month {

	static var asArray: [Month] {return self.allCases}

	var shortMonthName: String {
		switch self {
		case .january: return "jan"
		case .february: return "feb"
		case .march: return "mar"
		case .april: return "apr"
		case .may: return "may"
		case .june: return "jun"
		case .july: return "jul"
		case .august: return "aug"
		case .september: return "sep"
		case .october: return  "oct"
		case .november: return "nov"
		case .december: return "dec"
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
		}
	}
}
