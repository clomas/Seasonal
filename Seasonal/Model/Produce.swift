//
//  Produce.swift
//  Seasonal
//
//  Created by Clint Thomas on 21/11/20.
//  Copyright © 2020 Clint Thomas. All rights reserved.
//

import Foundation

struct Produce {
    let id: Int
    let name: String
    let category: ViewDisplayed.ProduceFilter
    let imageName: String
    let description: String // Not implemented yet
    let months: [Month]
    let seasons: [Season]
    var liked: Bool
}
