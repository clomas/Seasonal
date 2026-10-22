//
//  ProduceTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Testing
@testable import Seasonal

struct ProduceTests {

    @Test func withFavouriteOnlyChangesFavourite() {
        let produce = Produce.fixture(id: 3, name: "Kiwi", category: .fruit, months: [.may], seasons: [.winter])

        let favourite = produce.withFavourite(true)

        #expect(favourite.isFavourite)
        #expect(favourite.id == produce.id)
        #expect(favourite.name == produce.name)
        #expect(favourite.category == produce.category)
        #expect(favourite.months == produce.months)
        #expect(favourite.seasons == produce.seasons)
    }

    @Test func sortedByNameIsAlphabeticalWithUnnamedFirst() {
        let produce: [Produce] = [
            .fixture(id: 1, name: "Pear"),
            .fixture(id: 2, name: "Apple"),
            Produce(id: 3, name: nil, category: nil, imageName: nil, description: nil, months: nil, seasons: nil, isFavourite: false)
        ]

        #expect(produce.sortedByName().map(\.id) == [3, 2, 1])
    }
}
