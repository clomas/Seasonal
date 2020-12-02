//
//  DateHandler.swift
//  Seasonal
//
//  Created by Clint Thomas on 28/8/20.
//  Copyright © 2020 Clint Thomas. All rights reserved.
//

import Foundation

class DateHandler {

    static let instance = DateHandler()
    
func findMonthAndSeason() -> (Month, Season) {

        // find the current month and store the index
        let currentPageDate = Calendar.current.shortStandaloneMonthSymbols
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+8:00")! as TimeZone
        dateFormatter.dateFormat = "MMM"
        let today = Date()
        let currMonth = dateFormatter.string(from: today)

        //        ///////// FOR TESTING///////
        //        //Your current Date Format
        //        dateFormatter.dateFormat = "MMM"
        //        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        //        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        //        let finaldate = dateFormatter.date(from:"Jun")
        //        //Your changing Date Format
        //        //dateFormatter.dateFormat = "MMM"
        //        let second = dateFormatter.string(from: finaldate!)
        //        ///////// FOR TESTING///////

        let month = Month.asArray[(currentPageDate.firstIndex(of: currMonth) ?? 0) as Int]

        switch month {
        case .december, .january, .february:
            return (month, .summer)
        case .march, .april, .may:
            return (month, .autumn)
        case .june, .july, .august:
            return (month, .winter)
        case .september, .october, .november:
            return (month, .spring)
        }
    }

}
