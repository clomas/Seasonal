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

    @Test func withLikedOnlyChangesLiked() {
        let produce = Produce.fixture(id: 3, name: "Kiwi", category: .fruit, months: [.may], seasons: [.winter])

        let liked = produce.withLiked(true)

        #expect(liked.liked)
        #expect(liked.id == produce.id)
        #expect(liked.name == produce.name)
        #expect(liked.category == produce.category)
        #expect(liked.months == produce.months)
        #expect(liked.seasons == produce.seasons)
    }

    @Test func sortedByNameIsAlphabeticalWithUnnamedFirst() {
        let produce: [Produce] = [
            .fixture(id: 1, name: "Pear"),
            .fixture(id: 2, name: "Apple"),
            Produce(id: 3, name: nil, category: nil, imageName: nil, description: nil, months: nil, seasons: nil, liked: false)
        ]

        #expect(produce.sortedByName().map(\.id) == [3, 2, 1])
    }
}
