//
//  ProduceListTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI
import XCTest
@testable import Seasonal

@available(iOS 26, *)
final class ProduceListTests: XCTestCase {

    func testFilteredProduceReturnsAllWhenCategoryAll() {
        let p1 = Produce.fixture(id: 1, name: "Apple", category: .fruit)
        let p2 = Produce.fixture(id: 2, name: "Carrot", category: .vegetables)

        let view = ProduceList(produce: [p1, p2], parentTab: .favourites, selectedCategory: .all)

        XCTAssertEqual(view.filteredProduce.count, 2)
    }

    func testCategoryFiltering() {
        let p1 = Produce.fixture(id: 1, name: "Apple", category: .fruit)
        let p2 = Produce.fixture(id: 2, name: "Carrot", category: .vegetables)

        let view = ProduceList(produce: [p1, p2], parentTab: .favourites, selectedCategory: .vegetables)

        XCTAssertEqual(view.filteredProduce.count, 1)
        XCTAssertEqual(view.filteredProduce.first?.id, 2)
    }

    func testSearchFilteringIsCaseInsensitive() {
        let p1 = Produce.fixture(id: 1, name: "Apple", category: .fruit)
        let p2 = Produce.fixture(id: 2, name: "Carrot", category: .vegetables)

        let view = ProduceList(produce: [p1, p2], parentTab: .favourites, selectedCategory: .all, searchText: "app")

        XCTAssertEqual(view.filteredProduce.count, 1)
        XCTAssertEqual(view.filteredProduce.first?.id, 1)
    }

    func testEmptyListMessageForFavourites() {
        let view = ProduceList(produce: [], parentTab: .favourites, selectedCategory: .all)
        XCTAssertEqual(view.parentTab.emptyProduceListViewMessage, Strings.EmptyState.favourites)
    }
}
