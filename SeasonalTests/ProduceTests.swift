//
//  ProduceTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import XCTest
@testable import Seasonal

final class ProduceTests: XCTestCase {

    func testWithLikedOnlyChangesLiked() {
        let produce = Produce.fixture(id: 3, name: "Kiwi", category: .fruit, months: [.may], seasons: [.winter])

        let liked = produce.withLiked(true)

        XCTAssertTrue(liked.liked)
        XCTAssertEqual(liked.id, produce.id)
        XCTAssertEqual(liked.name, produce.name)
        XCTAssertEqual(liked.category, produce.category)
        XCTAssertEqual(liked.months, produce.months)
        XCTAssertEqual(liked.seasons, produce.seasons)
    }

    func testSortedByNameIsAlphabeticalWithUnnamedFirst() {
        let produce: [Produce] = [
            .fixture(id: 1, name: "Pear"),
            .fixture(id: 2, name: "Apple"),
            Produce(id: 3, name: nil, category: nil, imageName: nil, description: nil, months: nil, seasons: nil, liked: false)
        ]

        XCTAssertEqual(produce.sortedByName().map(\.id), [3, 2, 1])
    }
}
