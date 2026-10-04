//
//  ProduceRecordMapperTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import CloudKit
import XCTest
@testable import Seasonal

final class ProduceRecordMapperTests: XCTestCase {

    private let mapper = ProduceRecordMapper(location: .victoria)

    func testMapsAllFieldsForTheLocation() throws {
        let record = makeRecord(id: 7, name: "Apples", category: "fruit", months: "110000000011", seasons: "sum,aut")

        let produce = try XCTUnwrap(mapper.produce(from: [record]).first)

        XCTAssertEqual(produce.id, 7)
        XCTAssertEqual(produce.name, "Apples")
        XCTAssertEqual(produce.imageName, "Apples")
        XCTAssertEqual(produce.category, .fruit)
        XCTAssertEqual(produce.months, [.january, .february, .november, .december])
        XCTAssertEqual(produce.seasons, [.summer, .autumn])
        XCTAssertFalse(produce.liked)
    }

    func testCategoryMapping() {
        let records = ["vegetables", "herbs", "fruit", "anything-else"].enumerated().map { index, category in
            makeRecord(id: index, name: "Item", category: category, months: "", seasons: "")
        }

        XCTAssertEqual(mapper.produce(from: records).map(\.category), [.vegetables, .herbs, .fruit, .fruit])
    }

    func testSeasonsFollowCanonicalOrder() {
        let record = makeRecord(id: 1, name: "Item", category: "fruit", months: "", seasons: "spr win")

        XCTAssertEqual(mapper.produce(from: [record]).first?.seasons, [.winter, .spring])
    }

    func testOtherStatesFieldsAreIgnored() {
        let record = CKRecord(recordType: Constants.australianProduce)
        record.setValue(1, forKey: Constants.id)
        record.setValue("Item", forKey: Constants.name)
        record.setValue("fruit", forKey: Constants.category)
        record.setValue("111111111111", forKey: "months_nsw")
        record.setValue("sum", forKey: "seasons_nsw")

        let produce = mapper.produce(from: [record]).first

        XCTAssertEqual(produce?.id, 0, "A record missing this state's fields maps to the placeholder")
    }

    func testIncompleteRecordMapsToPlaceholder() {
        let record = CKRecord(recordType: Constants.australianProduce)

        let produce = mapper.produce(from: [record]).first

        XCTAssertEqual(produce?.id, 0)
        XCTAssertEqual(produce?.name, Constants.apple)
        XCTAssertEqual(produce?.months, [])
    }

    private func makeRecord(id: Int, name: String, category: String, months: String, seasons: String) -> CKRecord {
        let record = CKRecord(recordType: Constants.australianProduce)
        record.setValue(id, forKey: Constants.id)
        record.setValue(name, forKey: Constants.name)
        record.setValue(category, forKey: Constants.category)
        record.setValue(months, forKey: "months_vic")
        record.setValue(seasons, forKey: "seasons_vic")
        return record
    }
}
