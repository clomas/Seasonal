//
//  ProducePinningTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 13/11/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Testing
@testable import Seasonal

struct ProducePinningTests {

    private let produce: [Produce] = [
        .fixture(id: 1, name: "Apple"),
        .fixture(id: 2, name: "Banana", isFavourite: true),
        .fixture(id: 3, name: "Cherry"),
        .fixture(id: 4, name: "Date", isFavourite: true)
    ]

    @Test func favouriteIDsAreTheLikedProduce() {
        #expect(produce.favouriteIDs == [2, 4])
    }

    @Test func partitionKeepsOrderWithinEachSection() {
        let sections = produce.partitioned(pinning: [4, 2])

        #expect(sections.pinned.map(\.id) == [2, 4])
        #expect(sections.unpinned.map(\.id) == [1, 3])
    }

    @Test func partitionWithNoPinsLeavesEverythingUnpinned() {
        let sections = produce.partitioned(pinning: [])

        #expect(sections.pinned.isEmpty)
        #expect(sections.unpinned.map(\.id) == [1, 2, 3, 4])
    }

    @Test func partitionIgnoresIDsNotInTheList() {
        let sections = produce.partitioned(pinning: [99])

        #expect(sections.pinned.isEmpty)
        #expect(sections.unpinned.count == produce.count)
    }

    @Test func listItemsHeadBothSections() {
        let ids = produce.listItems(pinning: [2, 4]).map(\.id)

        #expect(ids == [
            "header.\(Strings.PinnedSection.favourites)", "produce.2", "produce.4",
            "header.\(Strings.PinnedSection.others)", "produce.1", "produce.3"
        ])
    }

    @Test(arguments: [Set<Int>(), [1, 2, 3, 4]])
    func listItemsHaveNoHeadersWithOnlyOneSection(_ pinned: Set<Int>) {
        let ids = produce.listItems(pinning: pinned).map(\.id)

        #expect(ids == ["produce.1", "produce.2", "produce.3", "produce.4"])
    }
}
