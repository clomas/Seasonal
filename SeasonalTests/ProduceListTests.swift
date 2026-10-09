//
//  ProduceListTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Testing
@testable import Seasonal

@MainActor
struct ProduceListTests {

    private let produce: [Produce] = [
        .fixture(id: 1, name: "Apple", category: .fruit),
        .fixture(id: 2, name: "Carrot", category: .vegetables)
    ]

    @Test(arguments: [
        (ProduceCategory.all, [1, 2]),
        (.fruit, [1]),
        (.vegetables, [2]),
        (.herbs, [])
    ])
    func categoryFiltering(_ category: ProduceCategory, expectedIDs: [Int]) {
        let list = ProduceList(produce: produce, parentTab: .favourites, selectedCategory: category)

        #expect(list.filteredProduce.map(\.id) == expectedIDs)
    }

    @Test(arguments: ["app", "APP", "Apple"])
    func searchFilteringIsCaseInsensitive(_ searchText: String) {
        let list = ProduceList(produce: produce, parentTab: .favourites, selectedCategory: .all, searchText: searchText)

        #expect(list.filteredProduce.map(\.id) == [1])
    }

    @Test func searchIgnoresDiacritics() {
        let list = ProduceList(produce: [.fixture(id: 3, name: "Jalapeño")], parentTab: .favourites, searchText: "jalapeno")

        #expect(list.filteredProduce.map(\.id) == [3])
    }

    @Test func searchAndCategoryCombine() {
        let list = ProduceList(produce: produce, parentTab: .favourites, selectedCategory: .vegetables, searchText: "app")

        #expect(list.filteredProduce.isEmpty)
    }
}
