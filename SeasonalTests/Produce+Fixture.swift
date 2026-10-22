//
//  Produce+Fixture.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

@testable import Seasonal

extension Produce {
    static func fixture(
        id: Int,
        name: String,
        category: ProduceCategory? = .fruit,
        months: [Months]? = nil,
        seasons: [Seasons]? = nil,
        isFavourite: Bool = false
    ) -> Produce {
        Produce(id: id, name: name, category: category, imageName: nil, description: nil, months: months, seasons: seasons, isFavourite: isFavourite)
    }
}
