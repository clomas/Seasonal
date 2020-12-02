//
//  PageStatus.swift
//  Seasonal
//
//  Created by Clint Thomas on 16/11/20.
//  Copyright © 2020 Clint Thomas. All rights reserved.
//

import Foundation

struct PageStatus {
    var month: Month
    var season: Season
    var onPage: ViewDisplayed
    var filter: ViewDisplayed.ProduceFilter
    var location: State
}
