//
//  AppStateViewModel.swift
//  Seasonal
//
//  Created by Clint Thomas on 17/11/20.
//  Copyright © 2020 Clint Thomas. All rights reserved.
//

import Foundation
import UIKit

// TODO: Move this shit into their own files. 
//enum Season: Int, CaseIterable {
//    case summer = 0
//    case autumn
//    case winter
//    case spring
//    case cancelled
//
//    static var asArray: [Season] {return self.allCases}
//
//    var asString: String {
//        switch self {
//        case .summer: return "summer"
//        case .autumn: return "autumn"
//        case .winter: return "winter"
//        case .spring: return "spring"
//        case .cancelled: return "cancelled"
//        }
//    }
//    var shortName: String {
//        switch self {
//        case .summer: return "sum"
//        case .autumn: return "aut"
//        case .winter: return "win"
//        case .spring: return "spr"
//        case .cancelled: return "can"
//        }
//    }
//}
//
//enum Month: Int, CaseIterable {
//    case january
//    case february
//    case march
//    case april
//    case may
//    case june
//    case july
//    case august
//    case september
//    case october
//    case november
//    case december
//
//    static var asArray: [Month] {return self.allCases}
//
//    var shortMonthName: String {
//        switch self {
//        case .january: return "jan"
//        case .february: return "feb"
//        case .march: return "mar"
//        case .april: return "apr"
//        case .may: return "may"
//        case .june: return "jun"
//        case .july: return "jul"
//        case .august: return "aug"
//        case .september: return "sep"
//        case .october: return  "oct"
//        case .november: return "nov"
//        case .december: return "dec"
//        }
//    }
//
//    var imageName: String {
//        switch self {
//        case .january: return "jan_curr.png"
//        case .february: return "feb_curr.png"
//        case .march: return "mar_curr.png"
//        case .april: return "apr_curr.png"
//        case .may: return "may_curr.png"
//        case .june: return "jun_curr.png"
//        case .july: return "jul_curr.png"
//        case .august: return "aug_curr.png"
//        case .september: return "sep_curr.png"
//        case .october: return "oct_curr.png"
//        case .november: return "nov_curr.png"
//        case .december: return "dec_curr.png"
//        }
//    }
//}

//extension Month {
//    func asInt() -> Int {
//        // 4 is the index of the collectionview where the filters are
//        return Month.asArray.firstIndex(of: self)!
//    }
//}

// Keep track of the current View that is shown
//enum ViewDisplayed: Int {
//    case favourites = 0
//    case monthPicker = 1
//    case months = 2
//    case seasons = 3
//
//	var titleString: String {
//		switch self {
//		case .favourites: return self.titleString
//		case .monthPicker: return Constants.selectAMonth
//		case .seasons: return Constants.Seasons
//		default:
//			return ""
//		}
//	}
//
//    enum ProduceFilter: Int, CaseIterable {
//        case all = 4
//        case fruit = 5
//        case vegetables = 6
//        case herbs = 7
//        case cancelled = 8
//
//        static var asArray: [ProduceFilter] {return self.allCases}
//
//        var asString: String {
//            switch self {
//			case .all: return Constants.all
//            case .fruit: return Constants.fruit
//			case .vegetables: return Constants.vegetables
//			case .herbs: return Constants.herbs
//			case .cancelled: return Constants.cancelled
//            }
//        }
//    }
//}

//extension ViewDisplayed.ProduceFilter {
//    func menuBarIndex() -> Int {
//        // 4 is the index of the collectionview where the filters are
//        return ViewDisplayed.ProduceFilter.asArray.firstIndex(of: self)! + 4
//    }
//}

final class AppStateViewModel {
    var status: StatusViewModel

    init(month: Month,
         season: Season,
         monthOrFavView: ViewDisplayed,
         category: ViewDisplayed.ProduceCategory,
         state: StateLocation) {

        let statusToInit = StatusViewModel.init(currentAppStatus: PageStatus(month: month,
                                                                             season: season,
                                                                             onPage: monthOrFavView,
                                                                             category: category,
                                                                             location: state))
        self.status = statusToInit
    }
}

struct StatusViewModel {
    var current: PageStatus!

    init(currentAppStatus: PageStatus) {
        self.current = currentAppStatus
    }
    var month: Month {
        get {
            return self.current.month
        } set(month) {
            self.current.month = month
        }
    }
    var season: Season {
        get {
            return self.current.season
        } set(season) {
            self.current.season = season
        }
    }
    var onPage: ViewDisplayed {
        get {
            return self.current.onPage
        } set(viewDisplayed) {
            self.current.onPage = viewDisplayed
        }
    }
    var category: ViewDisplayed.ProduceCategory {
        get {
            return self.current.category
        } set(category) {
            self.current.category = category
        }
    }
    var location: StateLocation {
        get {
            return self.current.location
        } set(location) {
            self.current.location = location
        }
    }
}



